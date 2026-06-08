extends CanvasLayer

signal tutorial_closed

func _ready() -> void:
	# 1. THE PAUSE OVERRIDE: Forces this entire UI layout to process clicks 
	# even when hud.gd freezes the rest of the 3D world game tree!
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. Force the mouse cursor to be completely visible over the viewport
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 3. Locate the button using your exact scene layout path
	var button = $BackgroundDim/TutorialWindow/VBoxContainer/StartButton
	
	if button:
		# 4. ZOMBIE CLEANUP: Disconnect any broken relative links left over in the editor
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)
		
		# 5. Force a fresh, mathematically perfect connection directly via code
		button.pressed.connect(_on_start_button_pressed)
		print("[TUTORIAL] All zombie links purged. Clean code connection active!")
	else:
		push_error("CRITICAL: Cannot find StartButton node path!")

func _on_start_button_pressed() -> void:
	print("[TUTORIAL] Instructions acknowledged. Commencing simulation...")
	
	# 1. Capture the mouse cursor back into the player's 3D perspective camera look
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 2. Tell hud.gd to unpause the engine and start ticking the GameTimer node
	tutorial_closed.emit()
	
	# 3. Cleanly wipe this tutorial layer out of memory
	queue_free()
