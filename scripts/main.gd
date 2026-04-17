extends Node3D

@export var player: Player

@onready var hotspots = $HotSpots
@onready var enemies = $Enemies

var hot_spots: Array[Vector3] = []

func _ready() -> void:
	for spot in hotspots.get_children():
		hot_spots.append(spot.position)
	
	for enemy in enemies.get_children():
		enemy.hot_spots = hot_spots
		enemy.start()
	
	player.connect("item_dropped", Callable(_item_dropped))

func _process(delta: float) -> void:
	for enemy in enemies.get_children():
		enemy.update(delta, player.global_position)

func _item_dropped(at: Vector3):
	for enemy in enemies.get_children():
		enemy.go_to(at)
