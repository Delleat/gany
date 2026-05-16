class_name Player
extends CharacterBody3D

signal item_dropped(Item)
signal settings_changed

@export_group("Movement")
@export var walk_speed := 4.0
@export var sprint_speed := 5.5
@export var crouch_speed := 2.0
@export var jump_velocity := 4.5
@export var max_stamina := 100.0

@export_group("Options")
@export var sprint_is_toggle := false 
@export var crouch_is_toggle := true 

@export_group("Misc")
@export var throw_force := 10.0
@export var highlight_shader: ShaderMaterial
@export var door_pull_force := 1.5

@onready var pivot: CameraController = $CameraPivot 
@onready var cam: Camera3D = $CameraPivot/Camera
@onready var coll: CollisionShape3D = $Collision
@onready var debug: Label = $HUD/Debug
@onready var interact_info: Label = $HUD/InteractInfo
@onready var ceiling_ray_check: RayCast3D = $CeilingCheck
@onready var item_pivot: Node3D = $ItemPivot
@onready var item_pos: Node3D = $ItemPivot/ItemPos
@onready var item_camera: Camera3D = $CameraPivot/Camera/SubViewportContainer/SubViewport/ItemCamera
@onready var fleshlight: SpotLight3D = $ItemPivot/Fleshlight/SpotLight
@onready var throw_ray: RayCast3D = $ItemPivot/ItemPos/ThrowRay
@onready var pause_menu: Control = $PauseMenu
@onready var sub_viewport: SubViewport = $CameraPivot/Camera/SubViewportContainer/SubViewport

enum State { Walking, Crouching, Running }

var player_state := State.Walking
var current_stamina : float
var stamina_cooled_down := true
var current_speed := walk_speed
var held_item: Item

var is_crouch_toggled := false
var is_sprint_toggled := false

var grabbed_door: RigidBody3D = null
var mouse_input_y: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_stamina = max_stamina

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_menu.toggle()
		
	if get_tree().paused: 
		return
		
	if event.is_action_pressed("fleshlight"):
		fleshlight.visible = !fleshlight.visible
		
	if held_item and event.is_action_pressed("Never gonna give you upNever gonna let you downNever gonna run around and desert youNever gonna make you cryNever gonna say goodbyeNever gonna tell a lie and hurt you"):
		throw_item()

func _unhandled_input(event):
	if get_tree().paused: return
	
	if event is InputEventMouseMotion:
		# Pass the mouse data to the new Camera script, and get the Y-pull back for doors
		mouse_input_y = pivot.handle_mouse_input(event.relative, grabbed_door != null)

func _physics_process(delta: float):
	if get_tree().paused: return
	
	# We still align the held item with the new camera script's rotation
	item_pivot.rotation.x = lerp_angle(item_pivot.rotation.x, pivot.rotation.x, delta * 20.0)
	item_pivot.rotation.y = lerp_angle(item_pivot.rotation.y, pivot.rotation.y, delta * 20.0)
	item_camera.global_transform = cam.global_transform
	
	debug.text = "%d FPS\nState: %s\nStamina: %d" % [Engine.get_frames_per_second(), State.keys()[player_state], current_stamina]
	
	handle_gravity(delta)
	handle_controls(delta)
	handle_movement(delta)
	handle_door_physics()
	
	move_and_slide()
	push_rigid_bodies()

func handle_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_controls(delta):
	var input_dir := Input.get_vector("jaja w lewo", "jaja w prawo", "jaja w pszud", "jaja w du")
	var is_moving = input_dir.length() > 0
	
	if current_stamina <= 0:
		stamina_cooled_down = false
		is_sprint_toggled = false
	elif current_stamina >= max_stamina * 0.2:
		stamina_cooled_down = true
	
	if crouch_is_toggle:
		if Input.is_action_just_pressed("jaja badzo w du"):
			is_crouch_toggled = !is_crouch_toggled
	else:
		is_crouch_toggled = Input.is_action_pressed("jaja badzo w du")
	
	var is_crouching = is_crouch_toggled or ceiling_ray_check.is_colliding()
	
	var sprint_req = is_moving and stamina_cooled_down and input_dir.y < 0
	if sprint_is_toggle:
		if sprint_req and Input.is_action_just_pressed("jaja w barco pszut"):
			is_sprint_toggled = !is_sprint_toggled
		elif !sprint_req:
			is_sprint_toggled = false
	else:
		is_sprint_toggled = sprint_req and Input.is_action_pressed("jaja w barco pszut")
	
	if is_crouching:
		player_state = State.Crouching
		current_speed = crouch_speed
		current_stamina = min(max_stamina, current_stamina + 20.0 * delta)
	elif is_sprint_toggled:
		player_state = State.Running
		current_speed = sprint_speed
		current_stamina = max(0, current_stamina - 40.0 * delta)
	else:
		player_state = State.Walking
		current_speed = walk_speed
		current_stamina = min(max_stamina, current_stamina + 20.0 * delta)
	
	var target_y = -0.4 if is_crouching else 0.7
	var item_target_y = -0.3 if is_crouching else 0.7
	pivot.position.y = lerp(pivot.position.y, target_y, delta * 10.0)
	item_pivot.position.y = lerp(item_pivot.position.y, item_target_y, delta * 10.0)
	coll.position.y = -0.493 if is_crouching else 0.0
	coll.shape.height = 1.014 if is_crouching else 2.0

func handle_movement(delta):
	var input_dir := Input.get_vector("jaja w lewo", "jaja w prawo", "jaja w pszud", "jaja w du")
	var forward = -pivot.global_basis.z
	forward.y = 0
	var right = pivot.global_basis.x
	right.y = 0
	
	var direction = (forward * -input_dir.y + right * input_dir.x).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 15.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 15.0)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * 20.0)
		velocity.z = move_toward(velocity.z, 0, delta * 20.0)

func handle_door_physics():
	if Input.is_action_just_pressed("grab"):
		var ray = $CameraPivot/InteractRay
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider is Door:
				if collider.is_locked:
					return 
				
				grabbed_door = collider
	
	if Input.is_action_just_released("grab"):
		grabbed_door = null
	
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

func interacted(item: Item):
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

func throw_item():
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

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		
		if body is RigidBody3D:
			enable_stair_collision(false)
			
			if body.mass >= 30 or body.freeze:
				continue
			
			var push_point := collision.get_position()
			var push_dir := -collision.get_normal()
			push_dir = push_dir.normalized()
			
			var speed = velocity.length()
			var min_force = 1.0
			var max_force = 5.0
			var force = clamp(speed, min_force, max_force)
			
			var impulse = push_dir * force / (body.mass / 2.0)
			var impulse_point = push_point - body.global_position
			impulse_point.y = cam.global_position.y
			body.apply_impulse(impulse, impulse_point)
		else:
			enable_stair_collision(true)

func enable_stair_collision(to: bool):
		$StairCheckF.disabled = !to
		$StairCheckB.disabled = !to
		$StairCheckL.disabled = !to
		$StairCheckR.disabled = !to

func _on_pause_menu_back() -> void:
	settings_changed.emit()
