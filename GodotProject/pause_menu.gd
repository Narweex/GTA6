extends CanvasLayer

func _ready():
	# Menü beim Start unsichtbar machen
	visible = false

func _input(event):
	# Test 1: Überprüfen, ob überhaupt eine Taste im Skript ankommt
	if event is InputEventKey and event.pressed:
		print("Taste gedrueckt: " + event.as_text())
		
	# Test 2: Überprüfen, ob die zugewiesene 'pause'-Aktion auslöst
	if event.is_action_pressed("pause"):
		print("PAUSE-AKTION WURDE ERKANNT!")
		toggle_pause()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	
	if new_pause_state:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_continue_button_pressed():
	toggle_pause()
