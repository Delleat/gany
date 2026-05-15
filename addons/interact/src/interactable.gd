extends RigidBody3D
class_name Interactable

signal interacted(body: Node)

@export var prompt_message := "Interact"
@export var prompt_input := "interact"

func get_prompt() -> String:
	var key := ""
	
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key = action.as_text_physical_keycode()
			break
	
	return prompt_message + "\n[" + key + "]"

func interact(body: Node) -> void:
	interacted.emit(body)
