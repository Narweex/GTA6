extends StaticBody3D

@export var riddle_id : String = "key_search"
@export var key_mesh : Node3D

func _ready() -> void:
	$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	if Progression.riddles.get(riddle_id, false) == true:
		print("The you have already completed this")
		return
	Progression.complete_riddle("key_search")
	key_mesh.queue_free()
	
func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Key obtained"
	return "Press [E] to obtain the key"
