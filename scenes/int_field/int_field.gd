## A specialized input widget that asks for an integer within range.
## It consists of an optional label and a [SpinBox].
@tool
extends HBoxContainer

## Emitted when the value has changed.
## [param value] is the new value.
signal value_changed(value: int)

@export_category("Int Field")

## The label. It is displayed alongside the field.
@export var label: String:
	set(value):
		_label = value
		call_deferred("_update_label", value)
	get:
		return _label

@export_group("Range")

## The minimum number. It must be less than [member max_value].
@export var min_value: int = 0:
	set(value):
		if value < _max_value:
			_min_value = value
		else:
			_min_value = _max_value - 1
		call_deferred("_set_range")
	get:
		return _min_value

## The maximum value allowed. It must be greater than [member min_value].
@export var max_value: int = 1:
	set(value):
		if value > _min_value:
			_max_value = value
		else:
			_max_value = _min_value + 1
		call_deferred("_set_range")
	get:
		return _max_value

## The default value.
@export var default_value: int = 0:
	set(value):
		_default_value = clampi(value, _min_value, _max_value)
		set_value(_default_value)
	get:
		return _default_value

@export_group("Help")

## An optional tooltip that is displayed when the cursor hovers over the label.
@export_multiline var help: String:
	set(value):
		_help = value
		call_deferred("_update_tooltip")
	get:
		return _help

## The value set by the widget.
var value: int:
	get:
		return get_value()
	set(value):
		call_deferred("set_value", value)

var _label: String
var _min_value: int
var _max_value: int
var _default_value: int
var _help: String

## Return the integer value.
func get_value() -> int:
	var int_number: SpinBox = $IntNumber
	return int(int_number.value)

## Set the integer value to [param _value].
func set_value(_value: int) -> void:
	var int_number: SpinBox = $IntNumber
	int_number.value = _value

func _update_label(text: String) -> void:
	var int_field_label: Label = $IntFieldLabel
	int_field_label.text = text
	if text:
		int_field_label.show()
	else:
		int_field_label.hide()

func _update_tooltip() -> void:
	$IntFieldLabel.tooltip_text = help

func _set_range() -> void:
	$IntNumber.min_value = min_value
	$IntNumber.max_value = max_value
	$IntNumber.tooltip_text = "Integer between the range [%d,%d]" % [min_value, max_value]

@warning_ignore("shadowed_variable")
func _on_int_number_value_changed(value: float) -> void:
	value_changed.emit(int(value))
