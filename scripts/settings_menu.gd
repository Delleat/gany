extends Control

@onready var res_box = $HBoxContainer/Visuals/Res/ResBox

func _ready() -> void:
	_setup_res_box()

func _setup_res_box():
	res_box.clear()
	res_box.add_item("1920x1080")
	res_box.set_item_metadata(0, Vector2i(1920, 1080))
	res_box.add_item("1280x720")
	res_box.set_item_metadata(1, Vector2i(1280, 720))


func _on_vsync_toggled(toggled_on: bool) -> void:
	SettingsData.vsync = toggled_on
func _on_sprint_toggle_toggled(toggled_on: bool) -> void:
	SettingsData.toggle_sprint = toggled_on

func _on_crouch_toggle_toggled(toggled_on: bool) -> void:
	SettingsData.toggle_crouch = toggled_on

func _on_camera_smoothing_toggled(toggled_on: bool) -> void:
	SettingsData.camera_smoothing = toggled_on

func _on_res_box_item_selected(index: int) -> void:
	var res_value = res_box.get_item_metadata(index)
	if res_value != null:
		SettingsData.screen_res = res_value
		DisplayServer.window_set_size(res_value)
	else:
		print("Error: No metadata set for this resolution index!")

	
func _on_wm_box_item_selected(index: int) -> void:
	match $HBoxContainer/Visuals/WindowMode/WMBox.get_item_id(index):
		0: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)  
