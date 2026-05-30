extends StaticBody3D

# Openable door sound reference 
@onready var open_sound: AudioStreamPlayer3D = $OpenCloseSound

@export_category("Door Settings")
## How long the rotation animation takes in seconds
@export var animation_time : float = 3

## Bestimmt die Drehrichtung: Wenn aktiviert, dreht sich die Tür in die eine Richtung, wenn deaktiviert in die andere.
@export var swing_clockwise : bool = true

@export_category("Progression Settings")
#this is absolute cooking masterpiece
## the exact string ID of the riddle required to unlock this door. Leave empty for normal doors.
@export var required_riddle_id : String = ""

var is_open : bool = false
var initial_rotation_y : float

func _ready() -> void:
	# Speichere die ursprüngliche Rotation der Tür, genau so, wie sie im Level platziert wurde
	initial_rotation_y = rotation.y
	
	# Connect the component's signal to our safety-check function
	$InteractableComponent.on_interact.connect(_on_door_interacted)

func _on_door_interacted() -> void:
	# If the door is already open, always allow closing it
	if is_open:
		_toggle_door()
		return
		
	# Check if the door requires a riddle to be solved
	if required_riddle_id != "":
		# Safely access the global Autoload 'Progression'
		if Progression.riddles.get(required_riddle_id, false) == true:
			_toggle_door()
		else:
			_on_door_locked()
	else:
		# No riddle required, function like a standard door
		_toggle_door()

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

func _on_door_locked() -> void:
	print("This door is locked! Requires completion of: ", required_riddle_id)
	# UI feedback or a 'locked handles rattle' sound effect can be played here

# Add this inside your door script

## This returns the text your RayCast will send to the UI
func get_prompt_text() -> String:
	if is_open:
		return "Press [E] to Close Door"
		
	# If closed, check if it's locked by a riddle
	if required_riddle_id != "" and not Progression.riddles.get(required_riddle_id, false):
		# Clean up the ID for the player (e.g., "cable_hex" -> "Cable Hex")
		var readable_name = required_riddle_id.replace("_", " ").capitalize()
		return "Locked: Requires " + readable_name
		
	return "Press [E] to Open Door"
