extends CheckButton

func _ready() -> void:
	button_pressed = Progression.challenge_mode
	toggled.connect(_on_check_button_toggled)

func _on_check_button_toggled(toggled_on: bool) -> void:
	#update the state 
	Progression.challenge_mode = toggled_on
