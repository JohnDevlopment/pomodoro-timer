## Config class. Loads a config file and sets its own variables.
extends Node

## Path to the config file.
const CONFIG_FILE := "user://config.ini"

## Number of times work timer is used before switching to long break.
var timers_work_counter: int = 3

## Notification timer in seconds.
var os_notification_time: int = 10

## True if the config was successfully loaded.
var loaded := false

func _ready() -> void:
	var logger: Logger = Logging.get_logger("config")
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

	os_notification_time = cf.get_value("os", "notification_time", UNDEFINED_INT)
	if os_notification_time == UNDEFINED_INT:
		push_warning("os/notification_time")

## Get a dictionary version of a config file.
## [br][br]
## [b]Returns[/b]: A [Dictionary] where each key is a section, that is,
## another dictionary of keys and values.
#func get_config(config: ConfigFile) -> Dictionary:
	#var cnf := {}
	#for section_name in config.get_sections():
		## Start section
		#var section := {}
		#cnf[section_name] = section
#
		#for key in config.get_section_keys(section_name):
			#cnf[key] = config.get_value(section_name, key)
#
	#return cnf

## Load the configuration from [param path].
## [br][br]
## [b]Returns[/b]: [code]Result<ConfigFile,String>[/code][br]
## On ok, the return value is the loaded config file, otherwise it is a
## [String] error message.
func load_config(path: String) -> Result:
	var cnf := ConfigFile.new()
	match cnf.load(path):
		OK:
			return Result.ok(cnf)
		var err:
			return Result.gderr(err)

## Save the configuration to [param path].
## [br][br]
## [b]Returns[/b]: [code]Result<ConfigFile,String>[/code][br]
## The config file that was saved.
func save_config(path: String) -> Result:
	var cnf := ConfigFile.new()
	
	cnf.set_value("timers", "work_counter", timers_work_counter)
	cnf.set_value("os", "notification_time", os_notification_time)
	
	match cnf.save(path):
		OK:
			return Result.ok(cnf)
		var err:
			return Result.gderr(err)
