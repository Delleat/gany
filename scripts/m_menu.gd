extends Node3D

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tet.tscn")

func _on_settings_pressed() -> void:
	pass # gowno potem


func _on_quit_pressed() -> void:
	get_tree().quit()
