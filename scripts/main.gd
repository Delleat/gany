extends Node3D

@export var player: CharacterBody3D

var hot_spots: Array[Vector3] = []

func _ready() -> void:
	for spot in $HotSpots.get_children():
		hot_spots.append(spot.position)
	
	for enemy in $Enemies.get_children():
		enemy.hot_spots = hot_spots
		enemy.start()

func _process(delta: float) -> void:
	for enemy in $Enemies.get_children():
		enemy.update(delta, player.global_position)
