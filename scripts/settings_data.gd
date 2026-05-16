extends Node

enum Diff {
	Easy,
	Medium,
	Hard,
	Extreme,
	Custom
}

# Player related settings
var toggle_sprint := false
var toggle_crouch := true
var camera_smoothing := true

# Game config
var difficulty := Diff.Medium

# Visual settings
var vsync := DisplayServer.VSYNC_DISABLED
var screen_res := Vector2i(1920, 1080)
var window_mode := DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
