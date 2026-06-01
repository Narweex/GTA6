extends StaticBody3D

@export_category("Riddle Settings")
@export var riddle_scene_path : String = "res://levels/open_safe/OpenSafeScene.tscn"
@export var safe_riddle_id : String = "open_safe"
@export var remote_riddle_id : String = "remote_use" 

@export var remote_mesh: Node3D 

func _ready() -> void:
	if has_node("InteractableComponent"):
		$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	# STATE 1: Safe is closed -> Launch the minigame
	if Progression.riddles.get(safe_riddle_id, false) == false:
		Progression.launch_minigame(safe_riddle_id, riddle_scene_path)
		return
		
	# STATE 2: Safe is open, remote is still inside -> Pick up the remote!
	if Progression.riddles.get(remote_riddle_id, false) == false:
		print("Remote acquired via safe secondary interaction loop!")
		
		# 1. Register the remote as solved/found in your global system
		Progression.complete_riddle(remote_riddle_id)
		
		# 2. Visually vanish the remote mesh from the safe interior
		if remote_mesh:
			remote_mesh.queue_free()
		return
		
	# STATE 3: Both are done
	print("Safe is completely empty.")

## Dynamic prompt text changes automatically based on game state!
func get_prompt_text() -> String:
	if Progression.riddles.get(safe_riddle_id, false) == false:
		return "Press [E] to decrypt safe lock"
		
	if Progression.riddles.get(remote_riddle_id, false) == false:
		return "Press [E] to take Safe Remote Control"
		
	return "The safe is empty"
