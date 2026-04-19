extends Interactable
class_name Thingies

@export var object_id := "test"
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
			if player.held_item == null and object_id != "chuj":
				show_temp_info("Your hand seems to not contain a Key")
				return
			sleeping = false
			var power = 20.0 
			var push_dir = (global_position - player.global_position).normalized()
			var handle_offset = global_basis.x * 0.5
			
			push_dir.y = 0
			
			apply_impulse(push_dir * power, handle_offset)
	
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
