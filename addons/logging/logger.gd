## Base class for all loggers.
@tool
extends RefCounted
class_name Logger

## Logging level enumeration.
enum Level {
	DEFAULT,
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

## Logging level. Cannot be set to [constant DEFAULT].
var level: Level:
	set(value):
		assert(value != Level.DEFAULT, "Invalid in this context")
		level = value

## Name of the logger.
var name: String

## Format of the logger's messages.
## Valid keys:
## [br] * date ([String]) - a date in the format of [member datetime_format]
## [br] * level ([String]) - the logging level
## [br] * name ([String]) - the logger's name
## [br] * msg ([String]) - the logging message
var format: String

## Format of the date string. Valid keys:
## [br] * year ([String]) - the year (i.e., 2000)
## [br] * month ([String]) - zero-padded month number (i.e., 03)
## [br] * day ([String]) - zero-padded day number (i.e., 01)
## [br] * timezone ([String]) - string name of the timezone
var datetime_format: String

## The function to call when a critical log is emitted.
## On _init, this is set to [method default_crash_behavior], but it
## can be changed later. The function must accept a string containing
## the error message.
var crash_behavior: Callable

var _colors: Array[StringName] = []

## Construct a logger with the given [param name] and [param level].
func _init(name: String, level: Level = Level.DEFAULT) -> void:
	var config := LoggingConfig.as_dict()

	# Set colors
	for ln in Level.keys():
		var level_name := (ln as String).to_lower()
		if level_name == "default":
			_colors.append("")
			continue
		var key := "colors/%s" % level_name
		var color: StringName = config[key]
		_colors.append(color)

	self.format = config['logger/format']
	self.name = name
	self.level = config['logger/level'] if level == Level.DEFAULT else level
	self.datetime_format = config['logger/datetime_format']
	self.crash_behavior = default_crash_behavior

func _log_internal(msg: String, log_level: Level) -> void:
	if _check_level(log_level):
		var color := _colors[log_level]
		var fields := {
			msg = msg,
			level = "[color=%s]%s[/color]" % [color, Level.find_key(log_level)],
			date = _format_datetime_string(),
			name = name
		}
		var formatted_message := format.format(fields)
		print_rich(formatted_message)
		match log_level:
			Level.WARNING:
				fields['level'] = Level.find_key(log_level)
				push_warning(format.format(fields))
			Level.ERROR:
				fields['level'] = Level.find_key(log_level)
				push_error(format.format(fields))
			Level.CRITICAL:
				fields['level'] = Level.find_key(log_level)
				push_error(format.format(fields))
				_crash_or_not(formatted_message)

func _crash_or_not(msg: String) -> void:
	assert(not Engine.is_editor_hint(), msg)
	crash_behavior.call(msg)

func _format_datetime_string():
	var fields := Time.get_datetime_dict_from_system()
	for key in ["hour", "minute", "second"]:
		fields[key] = "%02d" % fields[key]
	fields['timezone'] = Time.get_time_zone_from_system().name
	return datetime_format.format(fields)

func _format_message_string(fmt: String, args: Array = []) -> String:
	if args:
		return fmt % args
	return fmt

func _check_level(level: Level) -> bool:
	return level >= self.level

## Print a logging message with the severity 'debug'.
func debug(fmt: String, args: Array = []) -> void:
	var msg := _format_message_string(fmt, args)
	_log_internal(msg, Level.DEBUG)

## Print a logging message with the severity 'info'.
func info(fmt: String, args: Array = []) -> void:
	var msg := _format_message_string(fmt, args)
	_log_internal(msg, Level.INFO)

## Print a logging message with the severity 'error'.
func error(fmt: String, args: Array = []) -> void:
	var msg := _format_message_string(fmt, args)
	_log_internal(msg, Level.ERROR)

## Print a logging message with the severity 'warning'.
func warning(fmt: String, args: Array = []) -> void:
	var msg := _format_message_string(fmt, args)
	_log_internal(msg, Level.WARNING)

## Print a logging message with the severity 'critical'.
## This comes with the side effect of killing the process.
func critical(fmt: String, args: Array = []) -> void:
	var msg := _format_message_string(fmt, args)
	_log_internal(msg, Level.CRITICAL)

## Default behavior when a critical-level log is emitted.
static func default_crash_behavior(_msg: String) -> void:
	#if OS.has_feature("editor"):
		#assert(false)
	#OS.crash(msg)
	var tree := Logging.get_tree()
	tree.paused = true
	var timer := tree.create_timer(0.1)
	await timer.timeout
	tree.quit(1)
