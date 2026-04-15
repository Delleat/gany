@tool
extends EditorPlugin

var interactable = preload("./src/interactable.gd")

func _enter_tree() -> void:
	add_custom_type("Interactable", "RigidBody3D", interactable, preload("./res/debugempty.png"))

func _exit_tree() -> void:
	remove_custom_type("Interactable")
