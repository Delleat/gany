extends Control

var diff = SettingsData.Diff.Medium
@onready var btns = [
	$Menu/DifficultyBox/EasyBtn,
	$Menu/DifficultyBox/MediumBtn,
	$Menu/DifficultyBox/HardBtn,
	$Menu/DifficultyBox/ExtremeBtn,
	$Menu/DifficultyBox/CustomBtn
	]

func diff_btn_pressed(dif: SettingsData.Diff) -> void:
	diff = dif
	
	for btn in btns.size():
		btns[btn].button_pressed = diff == btn

func _on_easy_btn_pressed() -> void:
	diff_btn_pressed(SettingsData.Diff.Easy)

func _on_medium_btn_pressed() -> void:
	diff_btn_pressed(SettingsData.Diff.Medium)

func _on_hard_btn_pressed() -> void:
	diff_btn_pressed(SettingsData.Diff.Hard)

func _on_extreme_btn_pressed() -> void:
	diff_btn_pressed(SettingsData.Diff.Extreme)

func _on_custom_btn_pressed() -> void:
	diff_btn_pressed(SettingsData.Diff.Custom)

func _on_play_btn_pressed() -> void:
	SettingsData.difficulty = diff
	
	get_tree().change_scene_to_file("res://scenes/tet.tscn")
