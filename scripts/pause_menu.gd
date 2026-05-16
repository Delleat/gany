extends Control

signal back

func toggle() -> void:
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		visible = false
		Engine.time_scale = 1.0
	
		back.emit()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		visible = true
		Engine.time_scale = 0.0

func _on_settings_btn_pressed() -> void:
	$Settings.visible = true
	$Menu.visible = false

func _on_settings_back() -> void:
	$Settings.visible = false
	$Menu.visible = true

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
