extends Control

@onready var work_counter: Globals.IntField = %WorkCounter
@onready var notif_timer: HBoxContainer = %NotifTimer
@onready var settings_status: Globals.MessageLabel = %SettingsStatus

func _ready() -> void:
	_load_config()
	settings_status.show_info("Configuration loaded")

func _load_config():
	work_counter.value = Config.timers_work_counter
	notif_timer.value = Config.os_notification_time

func _on_save_pressed() -> void:
	Config.timers_work_counter = work_counter.value
	Config.os_notification_time = notif_timer.value
	Config.save_config(Config.CONFIG_FILE)
	settings_status.show_info("Configuration saved")

func _on_reset_pressed() -> void:
	_load_config()
	settings_status.show_info("Settings reset")
