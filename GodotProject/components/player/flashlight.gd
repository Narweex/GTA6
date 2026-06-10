extends SpotLight3D

@export var base_energy: float = 4.0        # Die normale Helligkeit der Lampe
@export var flicker_intensity: float = 0.5   # Wie stark das normale "Zittern" ist
@export var blackout_chance: float = 0.01   # Chance pro Frame, dass die Lampe kurz ausgeht (0.01 = 1%)

var is_blackout: bool = false
var blackout_timer: float = 0.0

func _process(delta: float) -> void:
	# An- und Ausschalten per Knopfdruck
	if Input.is_action_just_pressed("toggle_flashlight"):
		visible = !visible

	# Wenn die Taschenlampe ausgeschaltet ist, stoppen wir hier (kein Flackern im Hintergrund)
	if not visible:
		return

	# --- FLACKER-LOGIK ---
	# 1. Wenn die Lampe gerade in einem kompletten Aussetzer (Blackout) ist
	if is_blackout:
		blackout_timer -= delta
		light_energy = 0.0 # Licht komplett aus
		
		if blackout_timer <= 0.0:
			is_blackout = false # Aussetzer vorbei
			
	# 2. Wenn die Lampe normal leuchtet
	else:
		# Würfeln, ob genau in diesem Moment ein neuer Aussetzer startet
		if randf() < blackout_chance:
			is_blackout = true
			# Zufällige Dauer für den Aussetzer (zwischen 0.05 und 0.25 Sekunden)
			blackout_timer = randf_range(0.05, 0.25) 
			light_energy = 0.0
		else:
			# Kein Aussetzer? Dann normales, atmosphärisches Zittern berechnen
			var random_offset = randf_range(-flicker_intensity, flicker_intensity)
			light_energy = base_energy + random_offset
