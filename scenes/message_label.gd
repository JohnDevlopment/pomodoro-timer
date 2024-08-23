## A label used to display status messages.
extends RichTextLabel

var _active := false
var _last_entry := {}

func _ready() -> void:
	# Determine the height of the label using the selected font
	var height := _determine_label_height()
	custom_minimum_size.y = height

# Determines the height of the label using the current font.
func _determine_label_height() -> float:
	var font := get_theme_default_font()
	assert(is_instance_valid(font))
	var font_size := get_theme_default_font_size()
	assert(font_size > 0)
	var height = font.get_height(font_size)
	#_logger.debug("The average height of size %d font is %f", [font_size, height])
	return height

func _dict_eq(a: Dictionary, b: Dictionary) -> bool:
	assert(a.keys() == b.keys(), "dictionaries have different keys")
	for key in a:
		if a[key] != b[key]:
			return false
	return true

func _show_message(msg: String, prefix: String, color: StringName, time: float) -> void:
	assert(time > 0.0, "nonzero time required")
	
	# If the same arguments are passed, ignore
	var entry := {
		msg = msg,
		prefix = prefix,
		color = color,
		time = time
	}
	if _active and not _last_entry.is_empty() and _dict_eq(_last_entry, entry):
		#_logger.debug("Already did this")
		return
	
	_active = true
	_last_entry = entry
	text = "[color=%s]%s[/color]: %s" % [color, prefix, msg]
	$Timer.start(time)

func _finished() -> void:
	text = ""
	_active = false

## Show a message with the severity "error".
## [param time] controls how long to show the message.
func show_error(msg: String, time: float=5.0) -> void:
	_show_message(msg, "ERROR", "red", time)

## Show a message with the severity "info".
## [param time] controls how long to show the message.
func show_info(msg: String, time: float=5.0) -> void:
	_show_message(msg, "INFO", "green", time)

## Show a message with the severity "info".
## [param time] controls how long to show the message.
func show_warning(msg: String, time: float=5.0) -> void:
	_show_message(msg, "WARNING", "yellow", time)

# Signals

func _on_timer_timeout() -> void:
	_finished()
