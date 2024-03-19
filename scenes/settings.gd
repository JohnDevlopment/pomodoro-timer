extends Control

@onready var work_counter: Globals.IntField = %WorkCounter
@onready var notif_timer: HBoxContainer = %NotifTimer

func _ready() -> void:
	_load_config()

func _load_config():
	work_counter.value = Config.timers_work_counter
	notif_timer.value = Config.os_notification_time
	if OS.is_debug_build():
		print_debug("Config, set work counter to %d, actual value: %d" \
			% [Config.timers_work_counter, work_counter.value])

func _on_save_pressed() -> void:
	if OS.is_debug_build():
		print_debug("Saving config to '%s'..." % Config.CONFIG_FILE)
	Config.timers_work_counter = work_counter.value
	Config.os_notification_time = notif_timer.value
	Config.save_config(Config.CONFIG_FILE)

func _on_reset_pressed() -> void:
	_load_config()
