extends Node3D

func _on_play_pressed() -> void:
	$Control/Config.visible = true
	$Control/SelectMenu.visible = false

func _on_settings_pressed() -> void:
	$Control/Settings.visible = true
	$Control/SelectMenu.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_back() -> void:
	$Control/Settings.visible = false
	$Control/SelectMenu.visible = true

func _on_config_back() -> void:
	$Control/Config.visible = false
	$Control/SelectMenu.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
