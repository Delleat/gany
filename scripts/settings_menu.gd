extends Control

func _on_vsync_toggled(toggled_on: bool) -> void:
	SettingsData.vsync = toggled_on

func _on_sprint_toggle_toggled(toggled_on: bool) -> void:
	SettingsData.toggle_sprint = toggled_on

func _on_crouch_toggle_toggled(toggled_on: bool) -> void:
	SettingsData.toggle_crouch = toggled_on

func _on_camera_smoothing_toggled(toggled_on: bool) -> void:
	SettingsData.camera_smoothing = toggled_on
