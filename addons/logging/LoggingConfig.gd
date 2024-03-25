## Logging config singleton.
## This is responsible for providing configuration values for both
## [Logger] and the [code]Logging[/code] singleton. To use it, just make it
## an autoload and then use its properties. Alternatively, you can get a
## [Dictionary] from [method as_dict].
## @tutorial(Singletons/Autoloads): https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
@tool
extends Node

const CONFIG_FILE := "res://addons/logging/logging.cfg"

const SPECS := [
	# [logger]
	{
		section = "logger",
		key = "level",
		default = Logger.Level.INFO,
		property = &"logger_level"
	},
	{
		section = "logger",
		key = "format",
		default = "{level} {name} [{date}] {msg}",
		property = &"logger_format"
	},
	{
		section = "logger",
		key = "datetime_format",
		default = "{year}-{month}-{day}T{hour}:{minute}:{second}",
		property = &"logger_datetime_format"
	},
	
	# [colors]
	{
		section = "colors",
		key = "debug",
		default = &"green",
		property = &"color_debug"
	},
	{
		section = "colors",
		key = "info",
		default = &"blue",
		property = &"color_info"
	},
	{
		section = "colors",
		key = "warning",
		default = &"yellow",
		property = &"color_warning"
	},
	{
		section = "colors",
		key = "error",
		default = &"red",
		property = &"color_error"
	},
	{
		section = "colors",
		key = "critical",
		default = &"red",
		property = &"color_critical"
	}
]

## Default format for the [code]{date}[/code] field in [member logger_format].
## See [member Logger.datetime_format] for valid fields.
var logger_datetime_format: String = SPECS[2].default

## Default level for new loggers.
## See [enum Logger.Level].
var logger_level := Logger.Level.INFO

## Default format of logging messages.
## For valid fields, check [member Logger.format].
var logger_format := "{level} {name} [{date}] {msg}"

## Color for debug logs.
## See [Logger] for valid colors.
var color_debug := &"green"

## Color for info logs.
## See [Logger] for valid colors.
var color_info := &"blue"

## Color for warning logs.
## See [Logger] for valid colors.
var color_warning := &"yellow"

## Color for error logs.
## See [Logger] for valid colors.
var color_error := &"red"

## Color for critical logs.
## See [Logger] for valid colors.
var color_critical := &"red"

func _ready() -> void:
	# I'm wary of editing resources (res://) in non-editor builds
	if OS.has_feature("editor"):
		# Editor build, so we can modify resources
		if FileAccess.file_exists(CONFIG_FILE):
			# File exists, so we load it
			if OS.is_debug_build():
				print_debug("Loading %s..." % CONFIG_FILE)
			_load_config()
		else:
			# File does not exist, so we create it
			if OS.is_debug_build():
				if ProjectSettings.get_setting_with_override("jlogger/debug"):
					print_debug("Creating %s..." % CONFIG_FILE)
			_new_config()
	else:
		# In exported debug builds, simply die if config file doesn't exist
		assert(FileAccess.file_exists(CONFIG_FILE), "%s does not exist!" % CONFIG_FILE)

func _load_config() -> void:
	# Load the config file at CONFIG_FILE
	var cf := ConfigFile.new()
	var err := cf.load(CONFIG_FILE)
	assert(err == OK, error_string(err))
	for spec in SPECS:
		var value = cf.get_value(spec.section, spec.key)
		assert(value != null, "Undefined key '%s/%s'" % [spec.section, spec.key])
		set(spec.property, value)
		if OS.is_debug_build():
			print_debug("Set %s to %s" % [spec.property, value])

func _new_config() -> void:
	# Create a new config at CONFIG_FILE
	var cf := ConfigFile.new()
	
	for spec in SPECS:
		cf.set_value(spec.section, spec.key, spec.default)
	
	var err := cf.save(CONFIG_FILE)
	assert(err == OK, error_string(err))

## Return a [Dictionary] with all the config values.
## The keys defined therein are based on the elements in
## [constant SPECS]. Valid keys are:
## [br]
## - [code]colors/debug[/code] ([code]StringName[/code]) -
## Color used for debug logs.
## [br]
## - [code]colors/info[/code] ([code]StringName[/code]) -
## Color used for info logs.
## [br]
## - [code]colors/warning[/code] ([code]StringName[/code]) -
## Color used for warning logs.
## [br]
## - [code]colors/error[/code] ([code]StringName[/code]) -
## Color used for error logs.
## [br]
## - [code]colors/critical[/code] ([code]StringName[/code]) -
## Color used for critical logs.
func as_dict() -> Dictionary:
	var res := {}
	for spec in SPECS:
		var key := "%s/%s" % [spec.section, spec.key]
		var value = get(spec.property)
		assert(value != null, "Undefined: %s" % spec.property)
		res[key] = value
	return res
