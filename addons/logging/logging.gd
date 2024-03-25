@tool
extends EditorPlugin

func _enter_tree() -> void:
	if not ProjectSettings.has_setting("jlogger/debug"):
		ProjectSettings.set_setting("jlogger/debug", false)
		ProjectSettings.set_initial_value("jlogger/debug", false)
		ProjectSettings.add_property_info({
			name = "jlogger/debug",
			type = TYPE_BOOL
		})
		ProjectSettings.set_as_basic("jlogger/debug", true)
	
	add_autoload_singleton("LoggingConfig", "res://addons/logging/LoggingConfig.gd")
	add_autoload_singleton("Logging", "res://addons/logging/logging_autoload.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("Logging")
	remove_autoload_singleton("LoggingConfig")
