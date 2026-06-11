extends StaticBody3D

#i do not have the scene yet
@export_file("*.tscn") var riddle_scene_path : String = "res://levels/wire_riddle/WireRiddleScene.tscn"
@export var riddle_id : String = "wire_riddle"

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)
	

func _on_interact() -> void:
	# --- KORREKTUR HIER ---
	# Wenn key_search FALSE ist (also der Schlüssel noch nicht gefunden wurde), 
	# dann blockieren wir den Zugriff!
	if Progression.riddles.get("key_search", false) == false:
		print("Du musst erst den Schlüssel finden!")
		return
	# ----------------------
	
	if Progression.riddles.get(riddle_id, false) == true:
		print("The fuse is already fixed")
		return
		
	Progression.launch_minigame(riddle_id, riddle_scene_path)

func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Fixed fuse"
	return "Press [E] to fix the fuse"
