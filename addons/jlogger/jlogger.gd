@tool
extends EditorPlugin

var node_script := preload("res://addons/jlogger/logger_node.gd")

func _enter_tree() -> void:
	add_custom_type("LoggerNode", "Node", node_script, null)

func _exit_tree() -> void:
	remove_custom_type("LoggerNode")
