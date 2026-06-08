extends StaticBody3D

@export_file("*.tscn") var riddle_scene_path : String = "res://levels/cable_hex/CableHexScene.tscn"
@export var riddle_id : String = "cable_hex"
@onready var generator_sound: AudioStreamPlayer3D = $GeneratorSound

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)
	
	Progression.riddle_completed.connect(_on_global_riddle_completed)
	
	if Progression.riddles.get(riddle_id, false) == true:
		if generator_sound and not generator_sound.playing:
			generator_sound.play()

func _on_interact() -> void:
	if Progression.riddles.get(riddle_id, false) == true:
		print("The generator is already repaired")
		return
		
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func _on_global_riddle_completed(completed_id: String) -> void:
	if completed_id == riddle_id:
		print("SUCCESS: Cable hex solved. Booting generator audio core...")
		if generator_sound and not generator_sound.playing:
			generator_sound.play()

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Repaired generator"
	return "Press [E] to fix the generator"
