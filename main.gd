extends Control

## Default time label
const NULL_TIMER := "[center]--:--[/center]"

@onready var work_timer: Timer = $WorkTimer
@onready var break_timer: Timer = $BreakTimer
@onready var break_timer_long: Timer = $BreakTimerLong
@onready var timer_label: RichTextLabel = %TimerLabel
@onready var alarm: AudioStreamPlayer = $Alarm

var _timer_type := "work"
var _current_timer: Timer

func _ready() -> void:
	_change_timer("work")
	_initialize_timers()

func _process(_delta: float) -> void:
	_update_timer_label()

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
		if OS.is_debug_build():
			print_debug("%s timeout connected with word '%s'" % [node, word])
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
	# Change timer type to TYPE.
	match type:
		"work":
			_current_timer = work_timer
		"short":
			_current_timer = break_timer
		"long":
			_current_timer = break_timer_long
		_:
			push_error("Unknown type '%s'" % type)

## Stops the current timer and resets the label.
func _stop_timer() -> void:
	print_debug("Attempt to stop timer.")
	assert(is_instance_valid(_current_timer))
	_current_timer.stop()
	timer_label.text = NULL_TIMER

# Signals

func _on_start_timer_pressed() -> void:
	var timer := -1
	
	# DEBUG: set timer to value
	if OS.is_debug_build():
		var debug_timer: int = ProjectSettings.get_setting("debug/settings/project/timer.debug")
		timer = debug_timer
		print_debug("")
	
	if _current_timer.is_stopped():
		_current_timer.start(timer)

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
	_current_timer.paused = ! _current_timer.paused

func _on_work_timer_timeout(word: String) -> void:
	alarm.play()
	call_deferred("_on_stop_timer_pressed")
	match word:
		"work":
			os_notify("Work Over!", "Time to take a break!")
		"break":
			os_notify("Break Over!", "Get back to work, slave! Wahahaha!")
		"break_long":
			os_notify("Break Over!", "Get back to work! You've had long enough!")
