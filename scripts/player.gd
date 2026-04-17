class_name Player
extends CharacterBody3D

signal item_dropped(Vector3)

@export_category("Movement")
@export var walk_speed := 4.0
@export var sprint_speed := 5.5
@export var crouch_speed := 2.0
@export var jump_velocity := 4.5
@export var max_stamina := 100.0

@export_category("Camera")
@export var mouse_sensitivity := 0.002
@export var smoothing_amount := 15.0
@export var bob_freq := 2.0
@export var bob_amp := 0.05

@export_category("Misc")
@export var throw_force := 10.0
@export var highlight_shader: ShaderMaterial

@export_category("Options")
@export var can_sprint := true
@export var can_jump := false
@export var camera_smoothing := true

@onready var pivot = $Pivot
@onready var cam = $Pivot/Camera
@onready var coll = $Collision
@onready var debug = $HUD/Debug
@onready var ceiling_ray_check = $CeilingCheck
@onready var item_pivot = $ItemPivot
@onready var item_pos = $ItemPivot/ItemPos

var t_bob := 0.0
var target_rotation_x := 0.0
var target_rotation_y := 0.0
var current_speed := 0.0
var current_stamina := max_stamina

var is_crouching := false
var is_sprinting := false
var is_moving := false

var player_state := State.Walking

var current_item
var held_item: Item = null

enum State {
	Walking,
	Crouching,
	Running
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_speed = walk_speed

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if can_jump and Input.is_action_just_pressed("jaja_jup") and is_on_floor():
		velocity.y = jump_velocity
	
	var input_dir := Input.get_vector("jaja w lewo", "jaja w prawo", "jaja w pszud", "jaja w du")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		is_moving = true
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 15.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 15.0)
	else:
		is_moving = false
		velocity.x = move_toward(velocity.x, 0, current_speed * delta * 5.0)
		velocity.z = move_toward(velocity.z, 0, current_speed * delta * 5.0)
	
	# bobbig
	var dynamic_freq = bob_freq
	var dynamic_amp = bob_amp
	
	if is_sprinting:
		dynamic_freq = 3.5
		dynamic_amp = 0.08
	elif is_crouching:
		dynamic_freq = 1.5
		dynamic_amp = 0.03
	else:
		dynamic_freq = 2.4
	
	if is_on_floor() and velocity.length() > 0.1:
		t_bob += delta * velocity.length() 
		
		var pos = Vector3.ZERO
		pos.y = sin(t_bob * dynamic_freq) * dynamic_amp
		pos.x = cos(t_bob * dynamic_freq * 0.5) * dynamic_amp
		
		cam.transform.origin = cam.transform.origin.lerp(pos, delta * 10.0)
	else:
		cam.transform.origin = cam.transform.origin.lerp(Vector3.ZERO, delta * 10.0)
	
	# Jaja kurwa
	item_pivot.rotation = lerp(item_pivot.rotation, pivot.rotation, delta * 10)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		target_rotation_x -= event.relative.y * mouse_sensitivity
		target_rotation_y -= event.relative.x * mouse_sensitivity
		
		target_rotation_x = clamp(target_rotation_x, deg_to_rad(-80), deg_to_rad(80))

func _process(delta: float) -> void:
	debug.text = str(Engine.get_frames_per_second()) + " FPS\n " + str(player_state)
	
	# przepotezne kamera system smufing
	if camera_smoothing:
		rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * smoothing_amount)
		pivot.rotation.x = lerp(pivot.rotation.x, target_rotation_x, delta * smoothing_amount)
	else:
		rotation.y = target_rotation_y
		pivot.rotation.x = target_rotation_x
	
	# potezny crouching updatededed
	if Input.is_action_just_pressed("jaja badzo w du"):
		if is_crouching:
			if not ceiling_ray_check.is_colliding():
				is_crouching = false
		else:
			is_crouching = true
			
	if not is_crouching and ceiling_ray_check.is_colliding():
		is_crouching = true
	
	var target_y = -0.4 if is_crouching else 0.7
	
	item_pivot.position.y = 0.2 if is_crouching else 0.7
	coll.position.y = -0.493 if is_crouching else 0.0
	coll.shape.height = 1.014 if is_crouching else 2.0
	pivot.position.y = lerp(pivot.position.y, target_y, delta * 10.0)
	
	if Input.is_action_pressed("jaja w barco pszut") and can_sprint and not is_crouching and is_moving and current_stamina > 0.0 and velocity.length() > 0.1:
		is_sprinting = true
		current_stamina -= 0.8 * delta * 60
	else:
		is_sprinting = false
		if current_stamina < max_stamina:
			current_stamina += max_stamina / 10 * delta
	
	if current_stamina <= 0.0:
		can_sprint = false
		current_stamina = 0
	if not can_sprint and current_stamina >= max_stamina / 20.0:
		can_sprint = true
	
	if is_crouching:
		player_state = State.Crouching
	elif is_sprinting:
		player_state = State.Running
	else:
		player_state = State.Walking
	
	match player_state:
		State.Crouching:
			current_speed = crouch_speed
		State.Running:
			current_speed = sprint_speed
		State.Walking:
			current_speed = walk_speed
	
	if held_item and Input.is_action_just_pressed("Never gonna give you upNever gonna let you downNever gonna run around and desert youNever gonna make you cryNever gonna say goodbyeNever gonna tell a lie and hurt you"):
		throw_item()

func interacted(item: Item):
	if held_item: return
	held_item = item
	
	held_item.freeze = true
	held_item.reparent(item_pivot)
	
	held_item.position = item_pos.position
	held_item.rotation = item_pos.rotation
	
	held_item.set_collision_layer_value(4, false)

	var mesh_node = item.get_node_or_null("Mesh") 
	if mesh_node:
		var mat = mesh_node.get_active_material(0)
		if mat:
			mat.next_pass = null

func throw_item():
	var item_to_throw = held_item
	held_item = null
	
	item_to_throw.reparent(get_tree().root)
	item_to_throw.freeze = false
	
	item_to_throw.set_collision_layer_value(4, true)
	item_to_throw.set_collision_mask_value(4, true)
	
	var mesh_node = item_to_throw.get_node_or_null("Mesh")
	if mesh_node and highlight_shader:
		var mat = mesh_node.get_active_material(0)
		if mat:
			mat.next_pass = highlight_shader
	
	var throw_dir = -pivot.global_basis.z 
	item_to_throw.apply_central_impulse(throw_dir * throw_force)
	
	item_dropped.emit(item_to_throw.position)
