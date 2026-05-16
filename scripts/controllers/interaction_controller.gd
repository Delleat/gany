class_name InteractionController
extends Node3D

signal item_dropped(Item)


@export_group("Interaction Settings")
@export var throw_force := 10.0
@export var door_pull_force := 1.5
@export var highlight_shader: ShaderMaterial

@onready var player: CharacterBody3D = get_parent()
@onready var pivot: Node3D = get_node("../CameraPivot")
@onready var cam: Camera3D = get_node("../CameraPivot/Camera")
@onready var interact_ray: RayCast3D = get_node("../CameraPivot/InteractRay")
@onready var item_pivot: Node3D = get_node("../ItemPivot")
@onready var item_pos: Node3D = get_node("../ItemPivot/ItemPos")
@onready var throw_ray: RayCast3D = get_node("../ItemPivot/ItemPos/ThrowRay")
@onready var fleshlight: SpotLight3D = get_node("../ItemPivot/Fleshlight/SpotLight")
@onready var item_camera: Camera3D = get_node("../CameraPivot/Camera/SubViewportContainer/SubViewport/ItemCamera")

var held_item: Item
var grabbed_door: RigidBody3D = null
var mouse_input_y: float = 0.0

func _physics_process(delta: float) -> void:
	if get_tree().paused: return
	
	item_pivot.rotation.x = lerp_angle(item_pivot.rotation.x, pivot.rotation.x, delta * 20.0)
	item_pivot.rotation.y = lerp_angle(item_pivot.rotation.y, pivot.rotation.y, delta * 20.0)
	item_camera.global_transform = cam.global_transform
	
	handle_door_physics()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("fleshlight"):
		fleshlight.visible = !fleshlight.visible
		
	if event.is_action_pressed("grab"):
		if interact_ray.is_colliding():
			var collider = interact_ray.get_collider()
			if collider is Door and not collider.is_locked:
				grabbed_door = collider
				
	if event.is_action_released("grab"):
		grabbed_door = null
		
	if held_item and event.is_action_pressed("Never gonna give you upNever gonna let you downNever gonna run around and desert youNever gonna make you cryNever gonna say goodbyeNever gonna tell a lie and hurt you"):
		throw_item()

func is_grabbing_door() -> bool:
	return grabbed_door != null

func handle_door_physics() -> void:
	if grabbed_door:
		var push_dir = -pivot.global_basis.z
		push_dir.y = 0
		push_dir = push_dir.normalized()
		
		if abs(mouse_input_y) > 0.01:
			grabbed_door.sleeping = false
			var force_vector = push_dir * (-mouse_input_y * door_pull_force)
			var handle_offset = grabbed_door.global_basis.x * 0.5
			grabbed_door.apply_impulse(force_vector, handle_offset)
			mouse_input_y = 0.0

func interacted(item: Item) -> void:
	if held_item: return
	held_item = item
	held_item.freeze = true
	held_item.reparent(item_pivot)
	held_item.position = item_pos.position
	held_item.rotation = item_pos.rotation
	held_item.set_collision_layer_value(4, false)
	
	var mesh: MeshInstance3D = item.get_node("Mesh")
	mesh.set_layer_mask_value(1, false)
	mesh.set_layer_mask_value(2, true)
	mesh.get_active_material(0).next_pass = null

func throw_item() -> void:
	if not held_item: return
	var item_to_throw = held_item
	held_item = null
	
	item_dropped.emit(item_to_throw)
	item_to_throw.freeze = false
	item_to_throw.set_collision_layer_value(4, true)
	
	var mesh = item_to_throw.get_node("Mesh")
	mesh.set_layer_mask_value(1, true)
	mesh.set_layer_mask_value(2, false)
	mesh.get_active_material(0).next_pass = highlight_shader
	
	item_to_throw.global_position = pivot.global_position
	if !throw_ray.is_colliding():
		item_to_throw.apply_central_impulse(-pivot.global_basis.z * throw_force)
