extends CharacterBody3D
var base_camera_y: float = 0.0
@export_category("Movement Settings")
## Base speed of the character
@export var speed: float = 3.0
## Mouse sensitivity
@export var sensitivity: float = 0.002

@export_subgroup("Head Bobbing & Footsteps")
## Walking animation frequency
@export var bob_frequency: float = 3.2
## Walking animation intensity
@export var bob_amplitude: float = 0.06

@export_category("Inputs")
@export var left: String = "left"
@export var right: String = "right"
@export var forward: String = "forward"
@export var backward: String = "backward"

# Runtime animation variables
var t_bob: float = 0.0
var was_footstep_triggered: bool = false

# Node references
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer 

func _ready() -> void:
	# Capture the mouse for the first-person perspective
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	base_camera_y = camera.transform.origin.y

func _unhandled_input(event: InputEvent) -> void:
	# Handle looking around with the mouse
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# 1. Add gravity using your native project settings method
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector(left, right, forward, backward)
	var direction := (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# 3. Apply velocity or deceleration
	if direction and is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# 4. Execute the built-in physics movement
	move_and_slide()
	
	# 5. Safely calculate procedural camera bobbing and step sounds based on actual velocity
	_handle_head_bob(delta)

func _handle_head_bob(delta: float) -> void:
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if horizontal_velocity.length() > 0.1 and is_on_floor():
		t_bob += delta * horizontal_velocity.length() * bob_frequency
		var new_y = sin(t_bob) * bob_amplitude
		
		camera.transform.origin.y = base_camera_y + new_y
		# TRIGGER FOOTSTEP: When sin(t_bob) dips below -0.9, the simulated step hits the floor
		if sin(t_bob) < -0.9:
			if not was_footstep_triggered:
				_play_footstep_sound()
				was_footstep_triggered = true
		else:
			was_footstep_triggered = false
	else:
		t_bob = 0.0
		camera.transform.origin.y = move_toward(camera.transform.origin.y, base_camera_y, delta * 0.5)
func _play_footstep_sound() -> void:
	if footstep_player and footstep_player.stream:
		# Subtle pitch variation makes footsteps sound distinct and organic
		footstep_player.pitch_scale = randf_range(0.85, 1.05)
		footstep_player.play()
