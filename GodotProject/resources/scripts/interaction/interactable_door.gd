extends StaticBody3D
#openable door sound reference 
@onready var open_sound: AudioStreamPlayer3D = $OpenCloseSound

@export_category("Door Settings")
## How long the rotation animation takes in seconds
@export var animation_time : float = 3

## Bestimmt die Drehrichtung: Wenn aktiviert, dreht sich die Tür in die eine Richtung, wenn deaktiviert in die andere.
@export var swing_clockwise : bool = true

var is_open : bool = false
var initial_rotation_y : float

func _ready() -> void:
	# Speichere die ursprüngliche Rotation der Tür, genau so, wie sie im Level platziert wurde
	initial_rotation_y = rotation.y
	
	# Connect the component's signal to our door logic
	$InteractableComponent.on_interact.connect(_toggle_door)

func _toggle_door() -> void:
	is_open = !is_open	
	open_sound.play()
	# Lege fest, ob wir +90 Grad oder -90 Grad rechnen wollen, je nach Inspektor-Einstellung
	var offset := deg_to_rad(90) if swing_clockwise else deg_to_rad(-90)
	
	# Das neue Ziel ist entweder die Start-Rotation + 90 Grad (offen) oder wieder exakt die Start-Rotation (zu)
	var target_rotation_y := initial_rotation_y + offset if is_open else initial_rotation_y
	
	# Tween for smooth rotation
	var tween := create_tween()
	tween.tween_property(self, "rotation:y", target_rotation_y, animation_time).set_trans(Tween.TRANS_SINE)
