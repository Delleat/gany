extends Node3D

@export var player: Player
@export var debug := false

@onready var hotspots := $HotSpots
@onready var enemies := $Enemies
@onready var items := $Items

# { item: it's_last_y_level }
var items_to_inspect: Dictionary[Item, float] = {}
var hot_spots: Array[Vector3] = []

func _ready() -> void:
	print(SettingsData.vsync)
	player.crouch_is_toggle = SettingsData.toggle_crouch
	player.sprint_is_toggle = SettingsData.toggle_sprint
	player.camera_smoothing = SettingsData.camera_smoothing
	
	for spot in hotspots.get_children():
		hot_spots.append(spot.position)
	
	for enemy in enemies.get_children():
		enemy.hot_spots = hot_spots
		enemy.start()
		
		if debug:
			enemy.dbg_info.visible = true
	
	player.connect("item_dropped", _item_dropped)

func _physics_process(delta: float) -> void:
	for enemy in enemies.get_children():
		enemy.update(delta, player.global_position)
		
		if debug:
			enemy.debug()
	
	for item in items_to_inspect:
		if item.position.y == items_to_inspect[item]:
			items_to_inspect.erase(item)
			for enemy in enemies.get_children():
				if enemy.is_sound_sensitive:
					enemy.go_to(item.global_position)
		else:
			items_to_inspect[item] = item.position.y

func _item_dropped(item: Item):
	item.reparent(items)
	
	await get_tree().create_timer(0.05).timeout
	
	items_to_inspect.set(item, item.position.y)
