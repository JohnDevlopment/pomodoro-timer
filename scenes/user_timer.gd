extends Control

# Buttons
@onready var pause: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Pause
@onready var start: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Start
@onready var stop: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Stop

@onready var alarm: AudioStreamPlayer = %Alarm
@onready var timer: Timer = $Timer
@onready var time_value = %TimeValue
@onready var current_time_label: Label = $MarginContainer/VBoxContainer/CurrentTimeLabel

@onready var logger = $LoggerNode.logger

func _ready() -> void:
	var time = Globals.seconds_to_time(Config.timers_user_timer_seconds)
	logger.debug("Saved user timer seconds: %d (%s)",
		[Config.timers_user_timer_seconds, time])
	
	time_value.hours = time.hours
	time_value.minutes = time.minutes
	time_value.seconds = time.seconds
	
	time_value.time_value_changed.connect(_on_time_value_time_value_changed)

func _process(_delta: float) -> void:
	if timer.paused and timer.is_stopped():
		return
	_update_time_label()

func _update_time_label() -> void:
	# Format label to MM:SS.ms
	var time = Globals.seconds_to_time(timer.time_left)
	var seconds: float = snappedf(time.seconds, 0.01)
	current_time_label.text = "%02d:%02d:%05.2f" % [time.hours, time.minutes, seconds]

func _set_paused(value: bool) -> void:
	timer.paused = value
	pause.text = "Unpause" if value else "Pause"

func _stop() -> void:
	_set_paused(false)
	timer.stop()

func _play_alarm() -> void:
	assert(not alarm.playing, "Alarm is still playing")
	# Disable all buttons
	get_tree().call_group("buttons", "set_disabled", true)
	# Play alarm
	var rng = randf_range(0.98, 1.02)
	alarm.pitch_scale = rng
	logger.debug("Play alarm with pitch scale %f", [rng])
	alarm.play()
	await alarm.finished
	# Reset pitch
	alarm.pitch_scale = 1.0
	# Reset button status
	get_tree().call_group("buttons", "set_disabled", false)

func _save_config() -> void:
	var r = Config.save_config(Config.CONFIG_FILE)
	if r.is_err():
		logger.error("Failed to save config: %s", [r.err_value])
	else:
		logger.info("Saved config.")

# Signals

func _on_start_pressed() -> void:
	start.release_focus()
	timer.start(time_value.get_value())
	_set_paused(false)
	_save_config()

func _on_pause_pressed() -> void:
	pause.release_focus()
	_set_paused(timer.paused)

func _on_stop_pressed() -> void:
	stop.release_focus()
	_stop()

func _on_timer_timeout() -> void:
	_play_alarm()
	_stop()

func _on_time_value_time_value_changed(value: int) -> void:
	logger.debug("Value: %d", [value])
	var disabled := value == 0
	get_tree().call_group("buttons", "set_disabled", disabled)
	Config.timers_user_timer_seconds = value
