extends Interactable
class_name Thingies

@export var object_id := "test"
var is_locked := true
var info_tween: Tween
var interact_info
func interact(player: Node) -> void:
	interact_info = player.get_node("HUD/InteractInfo")
	match object_id:
		"test":
			if player.held_item != null:
				Engine.max_fps = 0
			else:
				Engine.max_fps = 17
		"door":
			if player.held_item == null and is_locked:
				show_temp_info("Your hand seems to be missing an important piece (Key)")
				return
			elif is_locked:
				is_locked = false # Odblokowujemy drzwi na stałe
				show_temp_info("The door is now unlocked.")
	
	super.interact(player)

func show_temp_info(message: String):
	if info_tween:
		info_tween.kill()
	
	interact_info.text = message
	interact_info.modulate.a = 1.0
	interact_info.visible = true

	info_tween = create_tween()
	info_tween.tween_interval(1.5)
	info_tween.tween_property(interact_info, "modulate:a", 0.0, 0.5)
	info_tween.tween_callback(func(): interact_info.visible = false)
