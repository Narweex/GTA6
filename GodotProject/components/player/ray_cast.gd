extends RayCast3D

@export_category("Interaction Settings")
## The input map action used to interact
@export var interact_action : String = "interact"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(interact_action):
		if is_colliding():
			var target = get_collider()
			
			# Search the target's children for InteractableComponent
			for child in target.get_children():
				if child is InteractableComponent:
					child.interact()
					break # Stop searching once we find it
