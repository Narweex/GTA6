extends CheckButton


func _ready() -> void:
	button_pressed = Progression.tutorial_enabled
	toggled.connect(_on_check_button_toggled)

func _on_check_button_toggled(toggled_on: bool) -> void:
	#update the state 
	Progression.tutorial_enabled = toggled_on
