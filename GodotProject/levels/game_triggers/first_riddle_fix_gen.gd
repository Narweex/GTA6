extends StaticBody3D

@export_file("*.tscn") var riddle_scene_path : String = "res://levels/cable_hex/CableHexScene.tscn"
@export var riddle_id : String = "cable_hex"

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	if Progression.riddles.get(riddle_id, false) == true:
		print("The generator is already repaired")
		return
		
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Repaired generator"
	return "Press [E] to fix the generator"
