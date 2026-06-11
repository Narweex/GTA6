extends SpotLight3D

@export var base_energy: float = 4.0        # Die normale Helligkeit der Lampe
@export var flicker_intensity: float = 0.5   # Wie stark das normale "Zittern" ist
@export var blackout_chance: float = 0.01   # Chance pro Frame, dass die Lampe kurz ausgeht

var is_blackout: bool = false
var blackout_timer: float = 0.0

func _process(delta: float) -> void:
	# 1. BATTERIE-LEER-CHECK: Wenn der Saft weg ist, bleibt die Lampe dunkel
	if Progression.flashlight_battery <= 0.0:
		visible = false
		light_energy = 0.0
		return

	# An- und Ausschalten per Knopfdruck
	if Input.is_action_just_pressed("toggle_flashlight"):
		visible = !visible
	
	# 2. BATTERIE-ABZUG: Frame-unabhängig mittels delta
	if visible: 
		Progression.flashlight_battery -= delta
		if Progression.flashlight_battery < 0.0:
			Progression.flashlight_battery = 0.0

	# Wenn die Taschenlampe ausgeschaltet ist, stoppen wir hier
	if not visible:
		return

	# --- FLACKER-LOGIK ---
	if is_blackout:
		blackout_timer -= delta
		light_energy = 0.0 
		
		if blackout_timer <= 0.0:
			is_blackout = false 
			
	else:
		if randf() < blackout_chance:
			is_blackout = true
			blackout_timer = randf_range(0.05, 0.25) 
			light_energy = 0.0
		else:
			var random_offset = randf_range(-flicker_intensity, flicker_intensity)
			light_energy = base_energy + random_offset
