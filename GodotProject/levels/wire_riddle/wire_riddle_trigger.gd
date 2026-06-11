extends StaticBody3D

#i do not have the scene yet
@export_file("*.tscn") var riddle_scene_path : String = "res://levels/wire_riddle/WireRiddleScene.tscn"
@export var riddle_id : String = "wire_riddle"

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)
	

func _on_interact() -> void:
	
	if Progression.riddles.get("key_search", false) == false:
		print("You need a key")
		return
	
	
	if Progression.riddles.get(riddle_id, false) == true:
		print("The fuse is already fixed")
		return
		
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Fixed fuse"
	
	if Progression.riddles.get("key_search", false) == false:
		return "Locked. Find the key"
	return "Press [E] to fix the fuse"
