extends Control

signal riddle_completed
signal riddle_cancelled

@onready var container = $HBoxContainer
@onready var button_left = $HBoxContainer/LeftButton
@onready var button_right = $HBoxContainer/RightButton
@onready var result_label = $ResultLabel 

var winning_button_index: int

func _ready() -> void:
	result_label.text = ""
	
	# Connect our interaction mappings
	button_left.pressed.connect(_on_button_pressed.bind(0))
	button_right.pressed.connect(_on_button_pressed.bind(1))
	
	if Progression.challenge_mode:
		winning_button_index = randi() % 2
		
		# Standard layout setup
		button_left.text = "DEFUSE?"
		button_right.text = "DEFUSE?"
		button_right.show()
	else:
		winning_button_index = 0
		button_right.hide()
		
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		button_left.text = "   DEFUSE   "
		
		_style_as_emergency_button(button_left)

func _on_button_pressed(clicked_button_index: int) -> void:
	button_left.disabled = true
	button_right.disabled = true
	
	if clicked_button_index == winning_button_index:
		result_label.text = "LAUNCH CANCELLED! Now get out of the facility!!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		result_label.text = "Skill issue. Error cascade initialized. Enjoy."
		result_label.add_theme_color_override("font_color", Color.RED)
	
	await get_tree().create_timer(2.0).timeout
	
	if clicked_button_index == winning_button_index:
		riddle_completed.emit()
	else:
		Progression.facility_detonated.emit()

## Generates a heavy industrial red button completely through code
func _style_as_emergency_button(btn: Button) -> void:
	# Font styling configurations
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.YELLOW)
	btn.add_theme_font_size_override("font_size", 22)
	
	# Base Style (The Unpressed Red Button)
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.75, 0.05, 0.05) # Deep Warning Red
	normal_style.border_color = Color(0.4, 0.0, 0.0) # Dark Industrial Rim
	normal_style.border_width_bottom = 8 # Thick bevel accent to look 3D and clicky
	normal_style.set_corner_radius_all(10) # Rounded slate block corners
	normal_style.set_content_margin_all(15) # Cushion padding around the label text
	
	# Hover Style (Glow Effect)
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.9, 0.1, 0.1) # Brighter radioactive red
	hover_style.shadow_color = Color(1.0, 0.0, 0.0, 0.3) # Soft volumetric light bloom
	hover_style.shadow_size = 12
	
	# Pressed Style (Flattened Button Effect)
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.5, 0.0, 0.0) # Compressed dark red
	pressed_style.border_width_bottom = 1 # Drops the bevel to simulate mechanical depth
	
	# Commit our newly minted styles to the button architecture overrides
	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new()) # Kills ugly selection lines
