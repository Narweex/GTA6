extends CanvasLayer

signal tutorial_closed

func _ready() -> void:
	if Progression.tutorial_enabled == false: 
		_on_start_button_pressed()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return

	process_mode = Node.PROCESS_MODE_ALWAYS
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var button = $BackgroundDim/VBoxContainer/StartButton
	
	if button:
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)
		
		button.pressed.connect(_on_start_button_pressed)
	
func _on_start_button_pressed() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	tutorial_closed.emit()
	
	queue_free()
