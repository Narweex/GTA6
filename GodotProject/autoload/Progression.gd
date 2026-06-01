extends Node
#this will be registered as a singleton. 
#track the progress of all riddles and base the walkthrough on it
signal riddle_completed(riddle_id: String)
signal riddle_cancelled(riddle_id: String)
signal stage_changed(riddle_id: String)

var riddles = {
	"cable_hex": false,
	"open_safe": false,
	"wire_loop": false,
	"circuit_gta": false,
	"chess_password": false,
	"fifty_fifty_button": false,
	"locker_key_found": false,
	"locker_unlocked": false,
	"captcha_riddle": false
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
	if not riddles["wire_loop"]:
		return "CURRENT OBJECTIVE: connect the wires"
	if not riddles["circuit_gta"]:
		return "CURRENT OBJECTIVE: crash into the circuit board"
	if not riddles["chess_password"]:
		return "CURRENT OBJECTIVE: Not Implemented"
	if not riddles["fifty_fifty_button"]:
		return "CURRENT OBJECTIVE: Oh no, what button do I press?"
	if not riddles["locker_key_found"]:
		return "CURRENT OBJECTIVE: Find a key in the storage room"
	if not riddles["locker_unlocked"]:
		return "CURRENT OBJECTIVE: Unlock the main door"
	if not riddles["captcha_riddle"]:
		return "CURRENT OBJECTIVE: Solve the final captcha code"
		
	return "All tasks completed! Escape!"

			
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
