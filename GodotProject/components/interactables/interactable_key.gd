extends StaticBody3D

@export var riddle_id : String = "key_search"

@onready var parent_key_mesh: Node3D = get_parent() as Node3D

func _ready() -> void:	
	$InteractableComponent.on_interact.connect(_on_interact)

func _on_interact() -> void:
	if Progression.riddles.get(riddle_id, false) == true:
		print("You have already completed this task.")
		return
		
	Progression.complete_riddle("key_search")
	
	if parent_key_mesh:
		parent_key_mesh.queue_free()
	
func get_prompt_text() -> String:
	if Progression.riddles.get(riddle_id, false) == true:
		return "Key obtained"
	return "Press [E] to obtain the key"
