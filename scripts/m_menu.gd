extends Node3D

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tet.tscn")

func _on_settings_pressed() -> void:
	$Control/Settings.visible = true
	$Control/SelectMenu.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_back() -> void:
	$Control/Settings.visible = false
	$Control/SelectMenu.visible = true
