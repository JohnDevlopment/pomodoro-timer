## A widget for specifying a time.
@tool
extends HBoxContainer

## One of the fields has been changed.
## [param value] is the total amount of seconds.
signal time_value_changed(value: int)

@onready var hours_field = $HoursField
@onready var minutes_field = $MinutesField
@onready var seconds_field = $SecondsField

## The hours field.
var hours: int = 0:
	get:
		return $HoursField.value
	set(value):
		$HoursField.value = value

## The minutes field.
var minutes: int = 0:
	get:
		return $MinutesField.value
	set(value):
		$MinutesField.value = value

## The seconds field.
var seconds: int = 0:
	get:
		return $SecondsField.value
	set(value):
		$SecondsField.value = value

func _ready() -> void:
	if not Engine.is_editor_hint():
		var fn = func(_v): time_value_changed.emit(get_value())
		(hours_field.value_changed as Signal).connect(fn)
		(minutes_field.value_changed as Signal).connect(fn)
		(seconds_field.value_changed as Signal).connect(fn)

## Return the time value converted to seconds.
func get_value() -> int:
	var res = Globals.time_to_seconds({
		hours = hours,
		minutes = minutes,
		seconds = seconds
	})
	return res
