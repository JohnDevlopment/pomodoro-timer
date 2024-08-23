## Config class. Loads a config file and sets its own variables.
extends Node

## Path to the config file.
const CONFIG_FILE := "user://config.ini"

## Number of times work timer is used before switching to long break.
var timers_work_counter: int = 3

## In the "User Timer" tab, the most recent timer value.
var timers_user_timer_seconds: int = 60

## Notification timer in seconds.
var os_notification_time: int = 10

## True if the config was successfully loaded.
var loaded := false

func _ready() -> void:
	var logger := Logger.new(Logger.Level.INFO, "config",
		func(_x): pass, "{level} {name}: {msg}", "")
	var r: Result
	if not FileAccess.file_exists(CONFIG_FILE):
		# Try to save config
		r = save_config(CONFIG_FILE)
		if r.is_err():
			# It's bad if we cannot save config
			logger.error("Error writing '%s': %s", [CONFIG_FILE, r.err_value])
			logger.warning("Config will not be saved.")
			return
	else:
		r = load_config(CONFIG_FILE)
		if r.is_err():
			logger.error("Error returned from load_config(): %s", [r.err_value])
			logger.warning("Using default values.")
			return
	
	_set_properties(r.expect("Expected ConfigFile!"))

func _set_properties(cf: ConfigFile) -> void:
	const UNDEFINED_INT := -1
	# TODO: Make function that automates this
	timers_work_counter = cf.get_value("timers", "work_counter", UNDEFINED_INT)
	if timers_work_counter == UNDEFINED_INT:
		push_warning("timers/work_counter not set in config")
		timers_work_counter = 3
	
	timers_user_timer_seconds = cf.get_value("timers", "user_timer_seconds", UNDEFINED_INT)
	if timers_user_timer_seconds == UNDEFINED_INT:
		push_warning("timers/user_timer_seconds not set in config")
		timers_user_timer_seconds = 60

	os_notification_time = cf.get_value("os", "notification_time", UNDEFINED_INT)
	if os_notification_time == UNDEFINED_INT:
		push_warning("os/notification_time")

## Load the configuration from [param path].
## [br][br]
## [b]Returns[/b]: [code]Result<ConfigFile,String>[/code][br]
## On ok, the return value is the loaded config file, otherwise it is a
## [String] error message.
func load_config(path: String) -> Result:
	var cnf := ConfigFile.new()
	match cnf.load(path):
		OK:
			return Result.Ok(cnf)
		var err:
			return Result.from_gderr(err)

## Save the configuration to [param path].
## [br][br]
## [b]Returns[/b]: [code]Result<ConfigFile,String>[/code][br]
## The config file that was saved.
func save_config(path: String) -> Result:
	var cnf := ConfigFile.new()
	
	cnf.set_value("timers", "work_counter", timers_work_counter)
	cnf.set_value("timers", "user_timer_seconds", timers_user_timer_seconds)
	cnf.set_value("os", "notification_time", os_notification_time)
	
	match cnf.save(path):
		OK:
			return Result.Ok(cnf)
		var err:
			return Result.from_gderr(err)
