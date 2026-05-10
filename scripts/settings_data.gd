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
var vsync := false
