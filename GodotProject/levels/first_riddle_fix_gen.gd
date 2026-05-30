# FuseBox.gd (Attached to your 3D puzzle object in the room)
extends StaticBody3D

## Path to your colleague's UI scene file (e.g. "res://scenes/cable_riddle.tscn")
@export_file("*.tscn") var riddle_scene_path : String = "res://levels/cable_hex/CableHexScene.tscn"
@export var riddle_id : String = "cable_hex"

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	# Check if it's already solved so they don't have to replay it
	if Progression.riddles.get(riddle_id, false) == true:
		print("This fusebox is already repaired.")
		return
		
	# Launch the riddle cleanly!
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Fusebox (Repaired)"
	return "Press [E] to Fix Wires"
