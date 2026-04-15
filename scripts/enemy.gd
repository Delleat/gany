class_name Enemy
extends CharacterBody3D

@export var walk_speed := 3.0
@export var run_speed := 4.0
@export var view_angle := 160.0
@export var idle_time := 3.0
@export var rotation_speed := 10.0

@onready var agent := $NavAgent
@onready var sight := $Eyes
@onready var v_a := cos(deg_to_rad(view_angle / 2.0))
@onready var idle_time_left := 0.0000001

var current_speed := walk_speed
var hot_spots: Array[Vector3] = []

func start() -> void:
	agent.velocity_computed.connect(Callable(_on_velocity_computed))
	agent.navigation_finished.connect(Callable(_on_navigation_finished))

func update(delta: float, player_pos: Vector3):
	sight.look_at(player_pos)
	
	var dir = (player_pos - global_position).normalized()
	
	var what_sees = sight.get_collider()
	if what_sees and what_sees.global_position == player_pos and -global_basis.z.dot(dir) > v_a:
		idle_time_left = 0.0
		current_speed = run_speed
		agent.set_target_position(what_sees.position)
	
	if idle_time_left > 0.0:
		idle_time_left -= delta
		if idle_time_left <= 0.0:
			agent.set_target_position(hot_spots.pick_random())
		return
	
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		return
	
	var dest: Vector3 = agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(dest) * current_speed
	if agent.avoidance_enabled:
		agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	if global_position.distance_to(dest) > 0.1:
		var target_dir = (dest - global_position)
		var target_angle = atan2(-target_dir.x, -target_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * rotation_speed)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func _on_navigation_finished() -> void:
	current_speed = walk_speed
	idle_time_left = idle_time
