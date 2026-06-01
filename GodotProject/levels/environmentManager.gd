extends Node3D 

@export_category("Scene References")
@onready var safe_door_node: Node3D = $interactable_safe_door

# Track if the ambient flickering should be alive
var is_power_restored: bool = false

func _ready() -> void:
	Progression.riddle_completed.connect(_on_riddle_solved)
	
	if Progression.riddles.get("cable_hex", false) == true:
		_turn_on_lights(true) 
		
	if Progression.riddles.get("open_safe", false) == true:
		_open_safe_animation(true)

func _on_riddle_solved(riddle_id: String) -> void:
	if riddle_id == "cable_hex":
		_turn_on_lights(false) 
		
	if riddle_id == "open_safe":
		_open_safe_animation(false)

func _open_safe_animation(instant: bool) -> void:
	if not safe_door_node: return
	var target_rotation_y: float = deg_to_rad(80)
	
	if instant:
		safe_door_node.rotation.y = target_rotation_y
	else:
		var tween = create_tween()
		tween.tween_property(safe_door_node, "rotation:y", target_rotation_y, 2.5)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)

# --- ADVANCED LIGHT CONTROLLER ---

func _turn_on_lights(instant: bool) -> void:
	var lights = get_tree().get_nodes_in_group("facility_lights")
	is_power_restored = true
	
	if instant:
		for light in lights:
			if light is Light3D:
				light.visible = true
		# Start background creepy flickering immediately
		_start_ambient_flicker_loop()
	else:
		# Run the intro boot-up flicker sequence, then start the loop
		await _dramatic_flicker(lights)
		_start_ambient_flicker_loop()

func _dramatic_flicker(lights: Array[Node]) -> void:
	_set_lights_visibility(lights, true)
	await get_tree().create_timer(0.15).timeout
	_set_lights_visibility(lights, false)
	await get_tree().create_timer(0.1).timeout
	_set_lights_visibility(lights, true)
	await get_tree().create_timer(0.2).timeout
	_set_lights_visibility(lights, false)
	await get_tree().create_timer(0.05).timeout
	_set_lights_visibility(lights, true)

func _set_lights_visibility(lights: Array[Node], is_visible: bool) -> void:
	for light in lights:
		if light is Light3D:
			light.visible = is_visible

## Endless background processing loop for random horror atmosphere
func _start_ambient_flicker_loop() -> void:
	while is_power_restored:
		# 1. Wait a random amount of time between flinches (e.g., 2 to 7 seconds of dead silence)
		await get_tree().create_timer(randf_range(2.0, 7.0)).timeout
		
		var lights = get_tree().get_nodes_in_group("facility_lights")
		if lights.is_empty(): continue
		
		var victim_light = lights.pick_random()
		if victim_light is Light3D and victim_light.visible:
			var base_energy = victim_light.light_energy
			
			for i in range(randi_range(1, 3)):
				victim_light.light_energy = base_energy * 0.1 # Drop to low brownout levels
				await get_tree().create_timer(randf_range(0.04, 0.08)).timeout
				victim_light.light_energy = base_energy
				await get_tree().create_timer(randf_range(0.03, 0.06)).timeout
