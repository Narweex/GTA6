extends Node

@export_file("*.tscn") var riddle_scene_path : String = "res://levels/open_safe/OpenSafeScene.tscn"
@export var riddle_id : String = "open_safe"

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	if Progression.riddles.get(riddle_id, false) == true:
		print("The safe is opened")
		return
		
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Safe opened"
	return "Press [E] to open the safe"
