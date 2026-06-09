extends StaticBody3D

func _ready() -> void:
	
	$InteractableComponent.on_interact.connect(_oeffne_raetsel)

func _oeffne_raetsel() -> void:
	
	var ui = get_node("WireRiddleUI")
	if ui:
		ui.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("Rätsel geöffnet!")
	else:
		print("Fehler: WireRiddleUI nicht gefunden!")
		


func _on_interactable_component_on_interact() -> void:
	pass # Replace with function body.
