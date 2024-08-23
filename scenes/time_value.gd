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
	get():
		return $HoursField.value
	set(value):
		$HoursField.value = value

## The minutes field.
var minutes: int = 0:
	get():
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
		(hours_field.value_changed as Signal).connect(_on_intfield_changed)
		(minutes_field.value_changed as Signal).connect(_on_intfield_changed)
		(seconds_field.value_changed as Signal).connect(_on_intfield_changed)

## Return the time value converted to seconds.
func get_value() -> int:
	return Globals.time_to_seconds({
		hours = hours,
		minutes = minutes,
		seconds = seconds
	})

# Signals

func _on_intfield_changed(_value: int) -> void:
	time_value_changed.emit(get_value())
