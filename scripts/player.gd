class_name Player
extends CharacterBody3D

signal item_dropped(Item)

@export_group("Movement")
@export var walk_speed := 4.0
@export var sprint_speed := 5.5
@export var crouch_speed := 2.0
@export var jump_velocity := 4.5
@export var max_stamina := 100.0

@export_group("Camera")
@export var mouse_sensitivity := 0.002
@export var smoothing_amount := 15.0
@export var bob_freq := 2.4
@export var bob_amp := 0.05

@export_group("Options")
@export var sprint_is_toggle := false # toggle for settings which we will not probably even use btw
@export var crouch_is_toggle := false # toggle for settings which we will not probably even use btw v2

@export_group("Misc")
@export var throw_force := 10.0
@export var highlight_shader: ShaderMaterial

@onready var pivot := $CameraPivot
@onready var cam := $CameraPivot/Camera
@onready var coll := $Collision
@onready var debug := $HUD/Debug
@onready var ceiling_ray_check := $CeilingCheck
@onready var item_pivot := $ItemPivot
@onready var item_pos := $ItemPivot/ItemPos
@onready var item_camera := $CameraPivot/Camera/SubViewportContainer/SubViewport/ItemCamera
@onready var fleshlight := $ItemPivot/Fleshlight/SpotLight3D

enum State { Walking, Crouching, Running }

var player_state := State.Walking
var current_stamina : float
var stamina_cooled_down := true
var current_speed := walk_speed
var t_bob := 0.0
var target_rotation_x := 0.0
var target_rotation_y := 0.0
var held_item: Item

var is_crouch_toggled := false
var is_sprint_toggled := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_stamina = max_stamina

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		target_rotation_x = clamp(target_rotation_x - event.relative.y * mouse_sensitivity, -1.4, 1.4)
		target_rotation_y -= event.relative.x * mouse_sensitivity

func _process(delta: float):
	pivot.rotation.x = lerp_angle(pivot.rotation.x, target_rotation_x, delta * smoothing_amount)
	pivot.rotation.y = lerp_angle(pivot.rotation.y, target_rotation_y, delta * smoothing_amount)
	
	item_pivot.rotation.x = lerp_angle(item_pivot.rotation.x, pivot.rotation.x, delta * 20.0)
	item_pivot.rotation.y = lerp_angle(item_pivot.rotation.y, pivot.rotation.y, delta * 20.0)
	
	item_camera.global_transform = pivot.global_transform
	handle_head_bob(delta)
	
	debug.text = "%d FPS\nState: %s\nStamina: %d" % [Engine.get_frames_per_second(), State.keys()[player_state], current_stamina]

func _physics_process(delta: float):
	handle_gravity(delta)
	handle_controls(delta)
	handle_movement(delta)
	
	if Input.is_action_just_pressed("fleshlight"):
		fleshlight.visible = !fleshlight.visible
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if held_item and Input.is_action_just_pressed("Never gonna give you upNever gonna let you downNever gonna run around and desert youNever gonna make you cryNever gonna say goodbyeNever gonna tell a lie and hurt you"):
		throw_item()
		
	move_and_slide()

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

	if sprint_is_toggle:
		if Input.is_action_just_pressed("jaja w barco pszut") and is_moving and stamina_cooled_down:
			is_sprint_toggled = !is_sprint_toggled
		if not is_moving or not stamina_cooled_down: 
			is_sprint_toggled = false
	else:
		is_sprint_toggled = Input.is_action_pressed("jaja w barco pszut") and is_moving and stamina_cooled_down

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

func handle_head_bob(delta):
	if is_on_floor() and velocity.length() > 0.1:
		t_bob += delta * velocity.length()
		cam.transform.origin.y = sin(t_bob * bob_freq) * bob_amp
		cam.transform.origin.x = cos(t_bob * bob_freq * 0.5) * bob_amp
	else:
		cam.transform.origin = cam.transform.origin.lerp(Vector3.ZERO, delta * 10.0)

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

func throw_item():
	if not held_item: return
	var item_to_throw = held_item
	held_item = null
	item_dropped.emit(item_to_throw)
	item_to_throw.reparent(get_tree().root)
	item_to_throw.freeze = false
	item_to_throw.set_collision_layer_value(4, true)
	var mesh = item_to_throw.get_node("Mesh")
	mesh.set_layer_mask_value(1, true)
	mesh.set_layer_mask_value(2, false)
	item_to_throw.apply_central_impulse(-pivot.global_basis.z * throw_force)
