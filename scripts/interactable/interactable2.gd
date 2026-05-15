extends Interactable
class_name Interactable2

signal _interacted(Player)

var info_tween: Tween
var interact_info

func interact(player: Node) -> void:
	interact_info = player.interact_info
	
	_interacted.emit(player)

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
