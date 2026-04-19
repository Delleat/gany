class_name Item
extends Interactable

@export var item_name := "Object"
@export var item_id := "generic_item"
@export var mesh : Resource
# collisionshape damy osobno moze do kazdego itemu jako child node
#@export var collision : CollisionShape3D

func _ready() -> void:
	$Mesh.mesh = mesh
	prompt_message = item_name + "\n" + "Pick Up"
	connect("interacted", _on_interacted)

func _on_interacted(player: Node):
	player.interacted(self)
