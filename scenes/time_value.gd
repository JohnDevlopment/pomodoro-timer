## A widget for specifying a time.
@tool
extends HBoxContainer

@export_category("TimeValue")

## The time
signal time_value_changed(value: int)

## The initial time value.
## Only effective if greater than 0.
@export var initial_time: int = 0

## The hours field.
var hours: int = 0:
	get():
		return $Hours.get_value()
	set(value):
		set_hours(value)

## The minutes field.
var minutes: int = 0:
	get():
		return $Minutes.get_value()
	set(value):
		set_minutes(value)

## The seconds field.
var seconds: int = 0:
	get():
		return $Seconds.get_value()
	set(value):
		set_seconds(value)

@onready var _hours = $Hours
@onready var _minutes = $Minutes
@onready var _seconds = $Seconds

func _ready() -> void:
	if not Engine.is_editor_hint():
		if initial_time > 0:
			var time = Globals.seconds_to_time(initial_time)
			set_hours(time.hours)
			set_minutes(time.minutes)
			set_seconds(time.seconds)
		
		(_hours.value_changed as Signal).connect(_on_intfield_changed)
		(_minutes.value_changed as Signal).connect(_on_intfield_changed)
		(_seconds.value_changed as Signal).connect(_on_intfield_changed)

## Return the time value converted to seconds.
func get_value() -> int:
	return (
		(_hours.get_value() * 60) +
		(_minutes.get_value() * 60) +
		_seconds.get_value()
	)

## Set the hours field.
func set_hours(value: int) -> void:
	$Hours.set_value(value)

## Set the minutes field.
func set_minutes(value: int) -> void:
	$Minutes.set_value(value)

## Set the seconds field.
func set_seconds(value: int) -> void:
	$Seconds.set_value(value)

## Get the formatted time string.
func as_string() -> String:
	var h: int = _hours.get_value()
	var m: int = _minutes.get_value()
	var s: int = _seconds.get_value()
	
	return "%02d:%02d:%02d" % [h, m, s]

# Signals

func _on_intfield_changed(_value: int) -> void:
	time_value_changed.emit(get_value())
