extends CharacterBody3D

@export_category("Movement Settings")
## base speed of the character
@export var speed : float = 5.0
## mouse sensitivity
@export var sensitivity : float = 0.002

@export_category("Inputs")
@export var left : String = "left"
@export var right : String = "right"
@export var forward : String = "forward"
@export var backward : String = "backward"

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle basic movement
	var input_dir := Input.get_vector(left, right, forward, backward)
	var direction := (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply velocity if moving on the ground
	if direction and is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Decelerate
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
