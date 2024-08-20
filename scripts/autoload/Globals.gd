## Globals and globally scoped helper functions.
extends Node

## The class behind [code]int_field.tscn[/code].
## Use for static typing.
const IntField = preload("res://scenes/int_field/int_field.gd")

## The class behind [code]message_label.tscn[/code].
## Use for static typing.
const MessageLabel = preload("res://scenes/message_label.gd")

func seconds_to_time(sec: float) -> Dictionary:
	var minutes := int(sec / 60.0)
	return {
		hours = sec / 3600.0,
		minutes = minutes,
		seconds = sec - float(minutes) * 60.0
	}
