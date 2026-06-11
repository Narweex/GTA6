extends StaticBody3D

@export_file("*.tscn") var win_scene_path: String = "res://components/game_won/GameWonScene.tscn"

func _ready() -> void:
	if has_node("InteractableComponent"):
		$InteractableComponent.on_interact.connect(_on_interact)
		
		_update_component_prompt()

func _on_interact() -> void:
	if _are_all_riddles_clear():
		var game_timer = get_node_or_null("/root/World/HUDLayer/HUD/GameTimer")
		var remaining_time: float = 0.0
	
		if game_timer and game_timer is Timer:
			remaining_time = game_timer.time_left
			game_timer.stop() 
	
		Progression.calculate_final_score(remaining_time)
	
		get_tree().change_scene_to_file(win_scene_path)
	else:
		_update_component_prompt()

func _are_all_riddles_clear() -> bool:
	for riddle_status in Progression.riddles.values():
		# If any riddle is still false, they cannot leave yet
		if riddle_status == false:
			return false
	return true

func _update_component_prompt() -> void:
	var current_text = get_prompt_text()
	if $InteractableComponent.has_method("set"):
		$InteractableComponent.set("prompt_text", current_text)
	elif "prompt_text" in $InteractableComponent:
		$InteractableComponent.prompt_text = current_text

## Dynamic text system read by your player raycast
func get_prompt_text() -> String:
	if _are_all_riddles_clear():
		return "Press [E] to open the door and ESCAPE!"
	return "The door is sealed shut. Complete all objectives first."
