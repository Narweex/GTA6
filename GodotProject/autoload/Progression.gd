extends Node
#this will be registered as a singleton. 
#track the progress of all riddles and base the walkthrough on it
var riddles = {
	"cable_hex": false,
	"button_order": false,
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
			
func launch_minigame(riddle_id: String, minigame_scene_path: String) -> void:
	# 1. Safely load and instance the UI scene
	var minigame_resource = load(minigame_scene_path)
	if not minigame_resource:
		push_error("Failed to load minigame path: " + minigame_scene_path)
		return
		
	var minigame_instance = minigame_resource.instantiate()
	
	minigame_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	minigame_instance.cable_hex_completed.connect(func():
		complete_riddle(riddle_id)
		_close_minigame(minigame_instance)
	)
	
	# 4. Add the overlay to the view screen
	get_tree().root.add_child(minigame_instance)
	
	# 5. Freeze the 3D World thread and release the cursor
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _close_minigame(instance: Node) -> void:
	# 1. Erase the UI scene completely
	instance.queue_free()
	
	# 2. Unfreeze the 3D world thread and recapture the mouse
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
