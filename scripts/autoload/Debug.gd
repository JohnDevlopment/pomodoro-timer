## Debug object.
extends Node

func print(msg: String, args: Array = []) -> void:
	if OS.is_debug_build():
		if args:
			print(msg % args)
		else:
			print(msg)
	pass
