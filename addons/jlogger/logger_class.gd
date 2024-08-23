## Logger object.
## [codeblock]
## var logger = Logger.new(Logger.Level.INFO, "main")
## [/codeblock]
extends RefCounted
class_name Logger

## Logging level.
enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

## A mapping of [enum Level] to color string.
const COLORS := {
	Level.DEBUG: "green",
	Level.INFO: "blue",
	Level.WARNING: "yellow",
	Level.ERROR: "red",
	Level.CRITICAL: "red"
}

## The logging level.
var level: Level

## The name of the logger.
var name: StringName

## The format of the logger.
## [br] * name (string) - the name of the logger
## [br] * level (string) - the logging level
## [br] * msg (string) - the logging message (required)
## [br] * date (string) - the date of the logging message
var format: String

## The format of the date field.
## [br] * year (string) - the year (i.e., 2000)
## [br] * month (string) - zero-padded month number (i.e., 03)
## [br] * day (string) - zero-padded day number (i.e., 01)
## [br] * hour (integer)
## [br] * minute (integer)
## [br] * second (integer)
## [br] * timezone (string) - name of the timezone
var datetime_format: String

## The function to call when a critical log is emitted.
## The function must accept a string containing the error message.
var crash_behavior: Callable

func _init(level: Level, name: StringName, crash_behavior: Callable,
format: String, datetime_format: String) -> void:
	self.level = level
	self.name = name
	self.crash_behavior = crash_behavior
	self.format = format
	self.datetime_format = datetime_format

func _check_level(level: Level) -> bool:
	return level >= self.level

func _format_datetime_string() -> String:
	var fields := Time.get_datetime_dict_from_system()
	for key in ["hour", "minute", "second"]:
		fields[key] = "%02d" % fields[key]
	fields['timezone'] = Time.get_time_zone_from_system().name
	return datetime_format.format(fields)

func _format_message(msg: String, args: Array) -> String:
	if args:
		return msg % args
	return msg

func _log_internal(level: Level, msg: String) -> void:
	if _check_level(level):
		var color = COLORS[level]
		var fields := {
			msg = msg,
			level = "[color=%s]%s[/color]" % [color, Level.find_key(level)],
			name = name
		}
		
		# Format date string
		if "{date}" in format:
			fields["date"] = _format_datetime_string()
		
		print_rich(format.format(fields))
		
		fields["level"] = Level.find_key(level)
		match level:
			Level.WARNING:
				push_warning(format.format(fields))
			Level.ERROR:
				push_error(format.format(fields))
			Level.CRITICAL:
				push_error(format.format(fields))
				_crash_or_not(msg.format(fields))

func _crash_or_not(msg: String) -> void:
	assert(not OS.has_feature("editor"), msg)
	crash_behavior.call(msg)

## Print a message with the severity 'debug'.
func debug(msg: String, args := []) -> void:
	msg = _format_message(msg, args)
	_log_internal(Level.DEBUG, msg)

## Print a message with the severity 'info'.
func info(msg: String, args := []) -> void:
	msg = _format_message(msg, args)
	_log_internal(Level.INFO, msg)

## Print a message with the severity 'warning'.
func warning(msg: String, args := []) -> void:
	msg = _format_message(msg, args)
	_log_internal(Level.WARNING, msg)

## Print a message with the severity 'error'.
func error(msg: String, args := []) -> void:
	msg = _format_message(msg, args)
	_log_internal(Level.ERROR, msg)

## Print a message with the severity 'critical'.
## Calling this function also crashes the program.
func critical(msg: String, args := []) -> void:
	msg = _format_message(msg, args)
	_log_internal(Level.CRITICAL, msg)
