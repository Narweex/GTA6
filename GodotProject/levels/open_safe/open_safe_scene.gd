extends Control

signal riddle_completed
signal riddle_cancelled

@export_category("Riddle Content")
@export var correct_word: String = "PITBULL"

@onready var container: VBoxContainer = $VBoxContainer
@onready var riddle_label: Label = $VBoxContainer/RiddleLabel
@onready var code_input: LineEdit = $VBoxContainer/CodeInput
@onready var submit_button: Button = $VBoxContainer/SubmitButton
@onready var feedback_label: Label = $VBoxContainer/FeedbackLabel

# Visual Juice Memory
var feedback_tween: Tween
var container_start_x: float

func _ready() -> void:
	container_start_x = container.position.x
	
	feedback_label.text = "ENTER THE PASSWORD"
	feedback_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4)) # Slate gray
	
	_apply_terminal_styling()
	
	# 3. Automatically grab focus so the player can type immediately
	code_input.grab_focus()
	code_input.placeholder_text = "AWAITING INPUT..."
	code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 4. Hook up submission events
	submit_button.pressed.connect(_on_submit_attempt)
	code_input.text_submitted.connect(func(_new_text): _on_submit_attempt())

func _unhandled_input(event: InputEvent) -> void:
	# Exit interface cleanly on cancel action
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
		riddle_cancelled.emit()

func _on_submit_attempt() -> void:
	# Prevent parsing bugs from clumsy typing
	var player_input = code_input.text.strip_edges().to_upper()
	var clean_answer = correct_word.strip_edges().to_upper()
	
	if player_input == clean_answer:
		_handle_success()
	else:
		_handle_failure()

func _handle_success() -> void:
	# Lock inputs completely
	code_input.editable = false
	submit_button.disabled = true
	
	# Animate the success message color cleanly
	_animate_feedback_color(Color.GREEN)
	feedback_label.text = "✔ DECRYPTION SUCCESSFUL. VAULT LOCKS RELEASED."
	
	# Give them a hot second to feel smart before closing
	await get_tree().create_timer(1.5).timeout
	riddle_completed.emit()

func _handle_failure() -> void:
	# Interrupt any running color shifts and flash alert red
	_animate_feedback_color(Color.RED)
	feedback_label.text = "✘ ACCESS DENIED: INVALID DATA STRING."
	
	# Trigger the physical terminal screen-shake juice!
	_trigger_ui_shake()
	
	# Clean slate for retry
	code_input.text = ""
	code_input.grab_focus()

## Smoothly blends the feedback label colors using a modern Tween loop
func _animate_feedback_color(target_color: Color) -> void:
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	
	feedback_tween = create_tween()
	feedback_tween.tween_property(feedback_label, "theme_override_colors/font_color", target_color, 0.25)

## Displaces the main container container back and forth rapidly to simulate an hardware error error bump
func _trigger_ui_shake() -> void:
	var shake = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var intensity: float = 12.0
	var speed: float = 0.04
	
	# Rapid oscillation array values
	shake.tween_property(container, "position:x", container_start_x + intensity, speed)
	shake.tween_property(container, "position:x", container_start_x - intensity, speed)
	shake.tween_property(container, "position:x", container_start_x + (intensity * 0.5), speed)
	shake.tween_property(container, "position:x", container_start_x - (intensity * 0.5), speed)
	# Snap home
	shake.tween_property(container, "position:x", container_start_x, speed)
## Generates a high-contrast terminal look completely through code architecture
func _apply_terminal_styling() -> void:
	# LineEdit Terminal Style
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.07, 0.07, 0.08) # Deep obsidian grey
	input_style.border_color = Color(0.2, 0.2, 0.25) # Subtle metal framing rim
	
	# FIX: Changed property assignment to method call
	input_style.set_border_width_all(2)
	
	input_style.set_content_margin_all(10)
	code_input.add_theme_stylebox_override("normal", input_style)
	code_input.add_theme_stylebox_override("focus", input_style)
	code_input.add_theme_font_size_override("font_size", 18)
	
	# Button Industrial Style
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.15, 0.15, 0.18)
	button_style.border_color = Color(0.3, 0.3, 0.35)
	
	# FIX: Changed property assignment to method call
	button_style.set_border_width_all(1)
	
	button_style.border_width_bottom = 4 # Gives a solid mechanical thickness
	button_style.set_content_margin_all(8)
	
	var button_hover = button_style.duplicate()
	button_hover.bg_color = Color(0.2, 0.2, 0.25)
	button_hover.shadow_color = Color(1, 1, 1, 0.05)
	button_hover.shadow_size = 8
	
	submit_button.add_theme_stylebox_override("normal", button_style)
	submit_button.add_theme_stylebox_override("hover", button_hover)
	submit_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	submit_button.text = "EXECUTE DECRYPTION RUN"
