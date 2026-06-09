extends Node
#this will be registered as a singleton. 
#track the progress of all riddles and base the walkthrough on it
signal riddle_completed(riddle_id: String)
signal riddle_cancelled(riddle_id: String)
signal stage_changed(riddle_id: String)
signal facility_detonated
var challenge_mode: bool = false
var tutorial_enabled: bool = true

var riddles = {
	"cable_hex": true,
	"open_safe": true,
	"remote_use": true,
	"key_search": false,
	"wire_riddle": false,
	"control_room": false,
	"fifty_fifty_button": false
}

#reset the game state on retry
func reset_game() -> void:
	riddles = {
		"cable_hex": false,
		"open_safe": false,
		"remote_use": false,
		"key_search": false,
		"wire_riddle": false,
		"fifty_fifty_button": false,
	}
	
func complete_riddle(riddle_id: String):
		if(riddles.has(riddle_id)):
			riddles[riddle_id] = true
			#for debugging
			print(riddle_id, " solved!")
			
			# send signal with new text for UI
			stage_changed.emit(get_current_stage_text())
			
			#emit the signal
			riddle_completed.emit(riddle_id)
			

#function that controls, where player currently is
func get_current_stage_text() -> String:
	if not riddles["cable_hex"]:
		return "CURRENT OBJECTIVE: Repair the generator wiring"
	if not riddles["open_safe"]:
		return "CURRENT OBJECTIVE: Find the safe in the office"
	if not riddles["remote_use"]:
		return "CURRENT OBJECTIVE: Use the remote from the safe"
	if not riddles["key_search"]:
		return "CURRENT OBJECTIVE: Find a key in the storage room with radioactive barells"
	if not riddles["control_room"]:
		return "CURRENT OBJECTIVE: Search for the control room to defuse the bomb"
	if not riddles["fifty_fifty_button"]:
		return "CURRENT OBJECTIVE: Oh no, what button do I press?"
	return "All tasks completed! Find the exit (it's marked with exit signs)"

			
func launch_minigame(riddle_id: String, minigame_scene_path: String) -> void:
	# 1. Safely load and instance the UI scene
	var minigame_resource = load(minigame_scene_path)
	if not minigame_resource:
		push_error("Failed to load minigame path: " + minigame_scene_path)
		return
		
	var minigame_instance = minigame_resource.instantiate()
	
	minigame_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	minigame_instance.riddle_completed.connect(func():
		complete_riddle(riddle_id)
		_close_minigame(minigame_instance)
	)
	
	minigame_instance.riddle_cancelled.connect(func():
		_close_minigame(minigame_instance)
		)
	
	# 4. Add the overlay to the view screen
	get_tree().root.add_child(minigame_instance)
	
	#get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _close_minigame(instance: Node) -> void:
	instance.queue_free()
	
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
