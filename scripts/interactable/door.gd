extends Interactable2
class_name Door

var is_locked := true

func _on__interacted(player: Player) -> void:
	if player.held_item == null and is_locked:
		show_temp_info("Your hand seems to be missing an important piece (Key)")
	elif is_locked:
		is_locked = false # Odblokowujemy drzwi na stałe
		freeze = false
		show_temp_info("The door is now unlocked.")
