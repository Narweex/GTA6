extends StaticBody3D

@export_category("Door Settings")
## How long the rotation animation takes in seconds
@export var animation_time : float = 0.5
## Move distance of door (always positive)
@export var distance : float = 1.0

@onready var leftside = $"left side"
@onready var rightside = $"right side"
@onready var collision = $CollisionShape3D

var is_open : bool = false

var left_initial_x : float
var right_initial_x : float

func _ready() -> void:
	left_initial_x = leftside.position.x
	right_initial_x = rightside.position.x
	
	$InteractableComponent.on_interact.connect(_toggle_door)

func _toggle_door() -> void:
	
	var wire_solved = Progression.riddles.get("wire_riddle", false)
	var safe_solved = Progression.riddles.get("open_safe", false)
	
	if not (wire_solved and safe_solved):
		print("locked gate, need remote and fixed wire")
		return
		
	if is_open:
		return
		
	is_open = true
	
	collision.set_deferred("disabled", true)
	
	var target_left_x := left_initial_x - distance
	var target_right_x := right_initial_x + distance
	
	var tween := create_tween().set_parallel(true)
	
	tween.tween_property(leftside, "position:x", target_left_x, animation_time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(rightside, "position:x", target_right_x, animation_time).set_trans(Tween.TRANS_SINE)
func get_prompt_text() -> String:
	if is_open:
		return "Door is open"
		
	
	if not Progression.riddles.get("open_safe", false):
		return "Locked. You need the remote"
	if not Progression.riddles.get("wire_riddle", false):
		return "Locked. Unblock the power"
		
	return "Press [E] to open"
