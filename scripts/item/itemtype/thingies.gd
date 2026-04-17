extends Interactable
class_name Thingies

@export var object_id := "test"

func interact(player: Node) -> void:
	match object_id:
		"test":
			if player.held_item != null:
				prank()
				Engine.max_fps = 0
			else:
				Engine.max_fps = 4
		"chuj":
			print("n g")
		"gowno":
			pass
	
	super.interact(player)

func prank():
	get_tree().free()
