extends Node3D

@export_category("Scene References")
@export var player_camera: Camera3D 
@export var whiteout_rect: ColorRect 

@export_category("Audio Players")
@onready var siren_player: AudioStreamPlayer3D = $SirenPlayer
@onready var explosion_player: AudioStreamPlayer3D = $ExplosionPlayer

# Runtime resolved nodes
var outside_sun: DirectionalLight3D

# States to be executed
var is_alarm_active: bool = false
var is_shaking: bool = false
var shake_intensity: float = 0.0

# Alarm Light Customization
var klaxon_rotation_speed: float = 5.0
var flash_speed: float = 12.0 # Higher values = faster flashing pulses
var alarm_time: float = 0.0

func _ready() -> void:
	Progression.facility_detonated.connect(trigger_facility_destruction)
	
func _process(delta: float) -> void:
	# 1. Rotate AND Pulse/Flash the red sirens across the environment
	if is_alarm_active:
		alarm_time += delta
		
		# Generate a smooth pulsing value oscillating cleanly between 0.0 and 1.0
		var pulse = (sin(alarm_time * flash_speed) + 1.0) / 2.0
		# Map that pulse to scale light energy dynamically from dim (0.5) to blinding intense red (5.0)
		var dynamic_energy = lerp(0.5, 5.0, pulse)
		
		var alarm_lights = get_tree().get_nodes_in_group("alarm_lights")
		for light in alarm_lights:
			if light is SpotLight3D:
				light.rotate_y(klaxon_rotation_speed * delta)
				light.light_energy = dynamic_energy
				
	# 2. Procedural camera viewport rumble
	if is_shaking and player_camera:
		player_camera.h_offset = randf_range(-shake_intensity, shake_intensity)
		player_camera.v_offset = randf_range(-shake_intensity, shake_intensity)

# The core destruction sequence
func trigger_facility_destruction() -> void:
	print("WARNING - Explosion sequence initialized. Running fail-safes...")
	
	# 1. DYNAMIC RUNTIME LOOKUPS
	if not player_camera:
		var cameras = get_tree().get_nodes_in_group("player_camera")
		if not cameras.is_empty(): player_camera = cameras[0] as Camera3D
		
	var suns = get_tree().get_nodes_in_group("sky_light")
	
	var whiteouts = get_tree().get_nodes_in_group("whiteout_screen")
	if not whiteouts.is_empty(): 
		whiteout_rect = whiteouts[0] as ColorRect
		
	# --- PHASE 1: THE ALARM LOCKDOWN & POWER FAILURE ---
	print("[EVENT] Cutting grid power. Turning on emergency backup frequencies...")
	
	# NEW: Kill all standard house/facility lights immediately
	var standard_lights = get_tree().get_nodes_in_group("facility_lights")
	for light in standard_lights:
		if light is Light3D:
			light.visible = false
			
	# Engage the emergency state processing loops
	is_alarm_active = true
	if siren_player:
		siren_player.play()
		
	# Ensure all emergency light nodes are visible so they can start processing their flash updates
	var alarm_lights = get_tree().get_nodes_in_group("alarm_lights")
	for light in alarm_lights:
		if light is Light3D:
			light.visible = true
			
	# Let the sirens wail and lights rotate for your exact 15-second suspense window
	await get_tree().create_timer(15.0).timeout
	
	# --- PHASE 2: THERMAL LIGHT SURGE & INITIAL IMPACT ---
	print("IMPACT TIME. INITIALIZING DETONATION EFFECTS...")
	
	# Overclock EVERY light tagged in the sky_light group
	for sun in suns:
		if sun is DirectionalLight3D:
			var light_tween = create_tween()
			sun.light_color = Color(1.0, 0.95, 0.85) # Nuclear white-hot hue
			
			light_tween.tween_property(sun, "light_energy", 120.0, 3.0)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)

	if explosion_player:
		explosion_player.play()
		
	# Start initial base building structural stress vibration
	is_shaking = true
	shake_intensity = 0.03
	
	await get_tree().create_timer(3.0).timeout
	
	# Severe close-proximity seismic displacement right before the blast wave hits
	shake_intensity = 0.15
	await get_tree().create_timer(1.0).timeout
	
	# --- PHASE 3: THE BLINDING WHITEOUT FLASHOVER ---
	if whiteout_rect:
		var tween = create_tween()
		tween.tween_property(whiteout_rect, "modulate:a", 1.0, 0.4)\
			.set_trans(Tween.TRANS_LINEAR)
			
		await tween.finished
		
	# --- PHASE 4: NARRATIVE RESOLUTION ---
	_handle_event_conclusion()

func _handle_event_conclusion() -> void:
	is_shaking = false
	is_alarm_active = false
	
	if player_camera:
		player_camera.h_offset = 0.0
		player_camera.v_offset = 0.0
		
	print("Facility eliminated. Loading GameOver sequence...")
	get_tree().change_scene_to_file("res://components/game_over/GameOverScene.tscn")
