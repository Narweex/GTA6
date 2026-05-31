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
	# 1. Sicherheits-Check: Wenn das Tor schon offen ist, mach gar nichts mehr
	if is_open:
		return
		
	is_open = true
	
	# 2. Kollision deaktivieren (sicher aufgeschoben für die Physik-Engine)
	collision.set_deferred("disabled", true)
	
	# Da es nur einmal aufgeht, brauchen wir kein "if is_open else ..." mehr
	var target_left_x := left_initial_x - distance
	var target_right_x := right_initial_x + distance
	
	var tween := create_tween().set_parallel(true)
	
	tween.tween_property(leftside, "position:x", target_left_x, animation_time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(rightside, "position:x", target_right_x, animation_time).set_trans(Tween.TRANS_SINE)
