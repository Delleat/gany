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

# Movement settings
func _on_sprint_toggle_toggled(toggled_on: bool) -> void:
	SettingsData.toggle_sprint = toggled_on

func _on_crouch_toggle_toggled(toggled_on: bool) -> void:
	SettingsData.toggle_crouch = toggled_on

func _on_camera_smoothing_toggled(toggled_on: bool) -> void:
	SettingsData.camera_smoothing = toggled_on

# Visual settings
func _on_vsync_box_item_selected(index: int) -> void:
	DisplayServer.window_set_vsync_mode(index)

func _on_res_box_item_selected(index: int) -> void:
	var res_value = res_box.get_item_metadata(index)
	
	# Crashes if devs fucked up
	assert(res_value, "Error: No metadata set for this resolution index!")
	
	SettingsData.screen_res = res_value
	DisplayServer.window_set_size(res_value)

func _on_wm_box_item_selected(index: int) -> void:
	DisplayServer.window_set_mode($HBoxContainer/Visuals/WindowMode/WMBox.get_item_id(index))
