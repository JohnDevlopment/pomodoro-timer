## A logger node.
extends Node

@export_category("Logger")

## The name of the logger.
@export var logger_name: StringName

## Logger level.
@export var logger_level: Logger.Level = Logger.Level.INFO

@export_group("Format")

## The format of each logger message.
@export var format := "{level} {name}: {msg}"

## Format of the 'date' field in [member logger_format].
@export var datetime_format := "{year}-{month}-{day}T{hour}:{minute}:{second}{timezone}"

## The internal logger.
var logger: Logger

func _ready() -> void:
	logger = Logger.new(logger_level, logger_name, default_crash_behavior, 
		format, datetime_format)

## The default crash behavior assigned to the logger.
func default_crash_behavior(_msg: String) -> void:
	var tree := get_tree()
	tree.paused = true
	await tree.create_timer(0.1).timeout
	tree.quit(1)
