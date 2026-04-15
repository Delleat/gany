# Item.gd
class_name Item
extends Interactable

@export_group("Item Info")
@export var item_name := "Object"
@export var item_id := "generic_item"

func _ready() -> void:
	prompt_message = item_name + "\n" + "Pick Up"
	connect("interacted", _on_interacted)

func _on_interacted(player: Node):
	player.interacted(self)
