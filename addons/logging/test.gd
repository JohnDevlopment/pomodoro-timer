extends Control

func _ready() -> void:
	var logger := Logger.new("test", Logger.Level.DEBUG)
	logger.debug("This is a log.")
	logger.info("This is a log.")
