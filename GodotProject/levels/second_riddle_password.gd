# FuseBox.gd (Attached to your 3D puzzle object in the room)
extends StaticBody3D

## Path to your colleague's UI scene file (e.g. "res://scenes/cable_riddle.tscn")
@export_file("*.tscn") var riddle_scene_path : String = "res://levels/cable_hex/PasswordGame.tscn"
@export var riddle_id : String = "chess_password"

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	# Check if it's already solved so they don't have to replay it
	if Progression.riddles.get(riddle_id, false) == true:
		print("Obtain the password codes")
		return
		
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Codes obtained"
	return "Press [E] to obtain codes"
