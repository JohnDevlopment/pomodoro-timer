extends Control

func _ready() -> void:
	var text: String = $MarginContainer/RichTextLabel.text
	var version = ProjectSettings.get_setting("application/config/version")
	text = text.format({version = version})
	$MarginContainer/RichTextLabel.text = text
