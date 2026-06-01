extends Control

signal riddle_completed
signal riddle_cancelled

@onready var button_left = $HBoxContainer/LeftButton
@onready var button_right = $HBoxContainer/RightButton
@onready var result_label = $ResultLabel 

var winning_button_index: int

func _ready():
	winning_button_index = randi() % 2
	
	button_left.pressed.connect(_on_button_pressed.bind(0))
	button_right.pressed.connect(_on_button_pressed.bind(1))
	
	result_label.text = ""

func _on_button_pressed(clicked_button_index: int):
	button_left.disabled = true
	button_right.disabled = true
	
	if clicked_button_index == winning_button_index:
		result_label.text = "You won!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		result_label.text = "You lost!"
		result_label.add_theme_color_override("font_color", Color.RED)
	
	await get_tree().create_timer(1.5).timeout
	
	if clicked_button_index == winning_button_index:
		riddle_completed.emit()
	else:
		riddle_cancelled.emit()
