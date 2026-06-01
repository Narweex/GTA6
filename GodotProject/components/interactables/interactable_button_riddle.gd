extends StaticBody3D

@export_file("*.tscn") var riddle_scene_path : String = "res://levels/fifty_fifty_button/FiftyFiftyButton.tscn"
@export var riddle_id : String = "fifty_fifty_button"

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	if Progression.riddles.get(riddle_id, false) == true:
		print("This was already done")
		return
		
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Ended"
	return "Press [E] to end the game"
