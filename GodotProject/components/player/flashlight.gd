extends SpotLight3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_flashlight"):
		visible = !visible
