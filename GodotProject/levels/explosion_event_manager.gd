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

# Warning lights rotation parameters
var klaxon_rotation_speed: float = 5.0

func _ready() -> void:
	# Hook into your global singleton event bus
	Progression.facility_detonated.connect(trigger_facility_destruction)
	
func _process(delta: float) -> void:
	# 1. Rotate the red sirens across the environment
	if is_alarm_active:
		var alarm_lights = get_tree().get_nodes_in_group("alarm_lights")
		for light in alarm_lights:
			if light is SpotLight3D:
				light.rotate_y(klaxon_rotation_speed * delta)
				
	# 2. Procedural camera viewport rumble
	if is_shaking and player_camera:
		player_camera.h_offset = randf_range(-shake_intensity, shake_intensity)
		player_camera.v_offset = randf_range(-shake_intensity, shake_intensity)

# The core destruction sequence
func trigger_facility_destruction() -> void:
	print("WARNING - Explosion sequence initialized. Running fail-safes...")
	# 1. DYNAMIC CAMERA LOOKUP
	if not player_camera:
		var cameras = get_tree().get_nodes_in_group("player_camera")
		if not cameras.is_empty(): player_camera = cameras[0] as Camera3D
		
	var suns = get_tree().get_nodes_in_group("sky_light")
	if not suns.is_empty(): outside_sun = suns[0] as DirectionalLight3D

	var whiteouts = get_tree().get_nodes_in_group("whiteout_screen")
	if not whiteouts.is_empty(): 
		whiteout_rect = whiteouts[0] as ColorRect
		
	# --- PHASE 1: THE ALARM LOCKDOWN ---
	is_alarm_active = true
	if siren_player:
		siren_player.play()
		
	# Instantly wake up and turn on all alarm-grouped red light components
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
		# Instantly blanket the screen layer in pure opaque white over 0.4 seconds
		tween.tween_property(whiteout_rect, "modulate:a", 1.0, 0.4)\
			.set_trans(Tween.TRANS_LINEAR)
			
		await tween.finished
		
	# --- PHASE 4: NARRATIVE RESOLUTION ---
	_handle_event_conclusion()

func _handle_event_conclusion() -> void:
	# Stop background loop processing steps safely
	is_shaking = false
	is_alarm_active = false
	
	# Zero out camera viewport offsets completely
	if player_camera:
		player_camera.h_offset = 0.0
		player_camera.v_offset = 0.0
		
	print("Facility eliminated. Loading GameOver sequence...")
	get_tree().change_scene_to_file("res://components/game_over/GameOverScene.tscn")
