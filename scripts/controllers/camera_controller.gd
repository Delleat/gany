class_name CameraController
extends Node3D

@export_group("Camera Settings")
@export var mouse_sensitivity := 0.002
@export var smoothing_amount := 15.0
@export var bob_freq := 2.4
@export var bob_amp := 0.05
@export var camera_smoothing := false

var target_rotation_x := 0.0
var target_rotation_y := 0.0
var t_bob := 0.0

@onready var cam: Camera3D = $Camera
@onready var player: CharacterBody3D = get_parent()

func _physics_process(delta: float):
	if get_tree().paused:
		return

	if camera_smoothing:
		rotation.x = lerp_angle(rotation.x, target_rotation_x, delta * smoothing_amount)
		rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * smoothing_amount)
	else:
		rotation.x = target_rotation_x
		rotation.y = target_rotation_y

	if player.is_on_floor() and player.velocity.length() > 0.1:
		t_bob += delta * player.velocity.length()
		cam.transform.origin.y = sin(t_bob * bob_freq) * bob_amp
		cam.transform.origin.x = cos(t_bob * bob_freq * 0.5) * bob_amp
	else:
		cam.transform.origin = cam.transform.origin.lerp(Vector3.ZERO, delta * 10.0)

func handle_mouse_input(relative: Vector2, is_grabbing_door: bool) -> float:
	if is_grabbing_door:
		target_rotation_y -= relative.x * (mouse_sensitivity * 0.5)
		return relative.y
	else:
		target_rotation_x = clamp(target_rotation_x - relative.y * mouse_sensitivity, -1.4, 1.4)
		target_rotation_y -= relative.x * mouse_sensitivity
		return 0.0
