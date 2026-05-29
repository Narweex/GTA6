extends CanvasLayer

func _ready():
	# Menü beim Start unsichtbar machen
	visible = false

func _input(event):
	# Überprüfen, ob die zugewiesene 'pause'-Aktion auslöst
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	
	if new_pause_state:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED





func _on_continue_pressed() -> void:
	toggle_pause()
