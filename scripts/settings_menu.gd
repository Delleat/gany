extends Control

signal back

func _on_vsync_toggled(toggled_on: bool) -> void:
	SettingsData.vsync = toggled_on

func _on_back_pressed() -> void:
	back.emit()
