extends Control

# Default time label
const NULL_TIMER := "[center]--:--[/center]"

# Timers
@onready var work_timer: Timer = %WorkTimer
@onready var break_timer: Timer = %BreakTimer
@onready var break_timer_long: Timer = %BreakTimerLong

# Options
@onready var type_work: CheckButton = %Type_Work
@onready var type_short: CheckButton = %Type_Short
@onready var type_long: CheckButton = %Type_Long

@onready var timer_label: RichTextLabel = %TimerLabel
@onready var alarm: AudioStreamPlayer = %Alarm
@onready var status: Globals.MessageLabel = %Status

var _timer_type := "work"
var _current_timer: Timer
var _work_counter: int

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("buttons"):
		var cb := func(button: Button):
			button.release_focus()
		(node as Button).pressed.connect(cb.bind(node))
	
	if true:
		var button: Button
		button = $Background/Tabs/Interface/VBoxContainer/HBoxContainer2/WCInc
		button.pressed.connect(
			func():
				_work_counter += 1
				_update_work_counter()
		)
		button = $Background/Tabs/Interface/VBoxContainer/HBoxContainer2/WCDec
		button.pressed.connect(_update_work_counter.bind(true))
		button = $Background/Tabs/Interface/VBoxContainer/HBoxContainer2/WCReset
		button.pressed.connect(_update_work_counter.bind(false, true))
	
	_update_work_counter(false, true)
	_change_timer("work")
	_initialize_timers()
	status.show_info("Interface loaded.")
	Logging.info("Interface loaded.")

func _process(_delta: float) -> void:
	_update_timer_label()

# Initializes timers. Connects signals.
func _initialize_timers():
	assert(is_instance_valid(_current_timer))

	# Connect timers' timeout signal
	var temp = [
		{
			node = work_timer,
			name = "work"
		},
		{
			node = break_timer,
			name = "break"
		},
		{
			node = break_timer_long,
			name = "break_long"
		}
	]
	for d in temp:
		var node: Timer = d.node
		var word: String = d.name
		node.timeout.connect(_on_work_timer_timeout.bind(word))

func _update_timer_label() -> void:
	if _current_timer.paused or _current_timer.is_stopped():
		return
	# Format label to MM:SS.ms
	var time = seconds_to_time(_current_timer.time_left)
	var seconds: float = snappedf(time.seconds, 0.01)
	timer_label.text = "[center]%02d:%05.2f[/center]" % [time.minutes, seconds]

func os_notify(title: String, message: String) -> void:
	var timeout := Config.os_notification_time * 1000
	OS.execute("notify-send", ["-t", timeout, title, message])

func seconds_to_time(sec: float) -> Dictionary:
	var minutes := int(sec / 60.0)
	return {
		minutes = minutes,
		seconds = sec - float(minutes) * 60.0
	}

func _change_timer(type: String):
	var old_type = _timer_type
	_timer_type = type
	# Change timer type to TYPE.
	match type:
		"work":
			_current_timer = work_timer
		"short":
			_current_timer = break_timer
		"long":
			_current_timer = break_timer_long
		_:
			# Restore previous timer type
			_timer_type = old_type
			Logging.error("Unknown type '%s'", [type])
			return
	Logging.debug("Change timer type to %s", [type])

# Stops the current timer and resets the label.
func _stop_timer() -> void:
	assert(is_instance_valid(_current_timer))
	_current_timer.paused = false
	_current_timer.stop()
	timer_label.text = NULL_TIMER

func _play_alarm() -> void:
	assert(not alarm.playing, "Alarm is still playing")
	# Disable all buttons
	get_tree().call_group("buttons", "set_disabled", true)
	# Play alarm
	var rng = randf_range(0.98, 1.02)
	alarm.pitch_scale = rng
	Logging.debug("Play alarm with pitch scale %f", [rng])
	alarm.play()
	await alarm.finished
	# Reset pitch
	alarm.pitch_scale = 1.0
	# Reset button status
	get_tree().call_group("buttons", "set_disabled", false)

# Update work counter. If decrement is true, decrements the counter.
# If reset is true, resets the counter to its configuration value.
func _update_work_counter(decrement: bool = false, reset: bool = false) -> void:
	if decrement:
		_work_counter = maxi(0, _work_counter - 1)
	elif reset:
		_work_counter = Config.timers_work_counter

	%WorkCounter.text = "Work Counter: %d" % _work_counter

# Signals

func _on_start_timer_pressed() -> void:
	if not _current_timer.is_stopped() and not _current_timer.paused:
		status.show_warning("Timer is already started")
		return

	# DEBUG: set timer to value
	var timer: int
	if true:
		const SETTING := "application/config/runtime/timer"
		timer = ProjectSettings.get_setting_with_override(SETTING)
		Logging.debug("Timer loaded from '%s': %d", [SETTING, timer])

	_current_timer.start(timer)
	_update_work_counter()

func _on_timer_type_changed(toggled_on: bool, type: String) -> void:
	assert(is_instance_valid(_current_timer))
	_stop_timer()
	if toggled_on:
		# Responding to the checkbutton that got toggled.
		# Change the timer to match type.
		# NOTE: _change_timer sets this automatically
		# _timer_type = type
		_change_timer(type)

func _on_stop_timer_pressed() -> void:
	_stop_timer()

func _on_pause_timer_pressed() -> void:
	if _current_timer.is_stopped():
		status.show_error("Cannot pause timer that is not started.")
		return
	_current_timer.paused = ! _current_timer.paused

func _on_work_timer_timeout(word: String) -> void:
	_play_alarm()
	_stop_timer()

	match word:
		"work":
			_update_work_counter(true)
			if _work_counter > 0:
				# Short break
				type_short.button_pressed = true
			else:
				# Long break
				type_long.button_pressed = true
			os_notify("Work Over!", "Time to take a break!")
		"break":
			type_work.button_pressed = true
			os_notify("Break Over!", "Get back to work, slave! Wahahaha!")
		"break_long":
			type_work.button_pressed = true
			_update_work_counter(false, true)
			os_notify("Break Over!", "Get back to work! You've had long enough!")
