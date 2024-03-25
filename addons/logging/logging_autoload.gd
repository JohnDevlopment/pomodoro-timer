## A singleton that can be used for logging purposes.
@tool
extends Node

var _logger: Logger
var _cache := {}

func _ready() -> void:
	if not Engine.is_editor_hint():
		_logger = get_logger()

## Returns a [Logger] with the given [param name] and [param level].
## Loggers returned from this function are cached using [param name]
## as the key. So, subsequent calls to this function with the same name
## will return the same exact logger.
func get_logger(name: StringName = &"", 
level: Logger.Level = Logger.Level.DEFAULT) -> Logger:
	# Root logger if name == "root" or ""
	if name == &"":
		name = &"root"
	
	# Return cached logger, if defined
	if name in _cache:
		return _cache[name]
	
	# Otherwise, create new logger and add to cache
	var logger := Logger.new(name, level)
	if OS.is_debug_build():
		print_debug("Creating logger: ", name)
	_cache[name] = logger
	return logger

## Prints a log with the severity debug.
func debug(fmt: String, args: Array = []) -> void:
	assert(is_instance_valid(_logger))
	_logger.debug(fmt, args)

## Prints a log with the severity info.
func info(fmt: String, args: Array = []) -> void:
	assert(is_instance_valid(_logger))
	_logger.info(fmt, args)

## Prints a log with the severity warning.
func warning(fmt: String, args: Array = []) -> void:
	assert(is_instance_valid(_logger))
	_logger.warning(fmt, args)

## Prints a log with the severity error.
func error(fmt: String, args: Array = []) -> void:
	assert(is_instance_valid(_logger))
	_logger.error(fmt, args)

## Prints a log with the severity critical.
func critical(fmt: String, args: Array = []) -> void:
	assert(is_instance_valid(_logger))
	_logger.critical(fmt, args)
