## Base class for all loggers.
## [codeblock]
## Logger(msg: String, log_level: Level)
## [/codeblock]
@tool
extends RefCounted
class_name Logger

## Logging level enumeration.
enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

## Logging level.
## See ["addons/logging/logging.gd"]
var level: Level

## Name of the logger.
## See ["addons/logging/settings.gd"]
var name: String

## Format of the logger's messages.
## See [code]settings.gd[/code].
var format: String

## Format of the date string.
## See [code]settings.gd[/code].
var datetime_format: String

## A mapping of levels to colors
const COLORS := {
	Level.DEBUG: "green",
	Level.INFO: "blue",
	Level.WARNING: "yellow",
	Level.ERROR: "red",
	Level.CRITICAL: "red"
}

## Construct a logger.
func _init(name: String, level) -> void:
	const SETTINGS := Logging.Settings
	self.format = SETTINGS.FORMAT
	self.datetime_format = SETTINGS.DATETIME_FORMAT
	self.name = name
	self.level = level

func _log_internal(msg: String, log_level: Level) -> void:
	var color: String = COLORS[log_level]
	var fields := {
		msg = msg,
		level = "[color=%s]%s[/color]" % [color, Level.find_key(log_level)],
		date = _formate_datetime_string()
	}
	print_rich(format.format(fields))

func _formate_datetime_string():
	var fields := Time.get_datetime_dict_from_system()
	for key in ["hour", "minute", "second"]:
		fields[key] = "%02d" % fields[key]
	fields['timezone'] = Time.get_time_zone_from_system().name
	return datetime_format.format(fields)

func _format_message_string(fmt: String, args: Array = []) -> String:
	if args:
		return fmt % args
	return fmt

func debug(fmt: String, args: Array = []) -> void:
	var msg := _format_message_string(fmt, args)
	_log_internal(msg, Level.DEBUG)

func info(fmt: String, args: Array = []) -> void:
	var msg := _format_message_string(fmt, args)
	_log_internal(msg, Level.INFO)
