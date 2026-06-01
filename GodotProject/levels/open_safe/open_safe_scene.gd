extends Control

signal riddle_completed
signal riddle_cancelled

@export_category("Riddle Content")
## The text riddle shown to the player on the safe console
@export_multiline var riddle_text: String = "I consume iron, I am born from water and air, I am the color of this forgotten facility. What am I?"
## The correct answer word (Case-insensitive)
@export var correct_word: String = "RUST"

@onready var riddle_label: Label = $VBoxContainer/RiddleLabel
@onready var code_input: LineEdit = $VBoxContainer/CodeInput
@onready var submit_button: Button = $VBoxContainer/SubmitButton
@onready var feedback_label: Label = $VBoxContainer/FeedbackLabel

func _ready() -> void:
	# 1. Initialize text layouts
	riddle_label.text = riddle_text
	feedback_label.text = "ENTER CYLINDER OVERRIDE CODE"
	feedback_label.add_theme_color_override("font_color", Color.DARK_GRAY)
	
	# 2. Automatically grab focus so the player can type immediately without clicking
	code_input.grab_focus()
	code_input.placeholder_text = "INPUT VALUE..."
	code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 3. Hook up submission events
	submit_button.pressed.connect(_on_submit_attempt)
	code_input.text_submitted.connect(func(_new_text): _on_submit_attempt())

func _unhandled_input(event: InputEvent) -> void:
	# Let the player close out of the lockbox UI safely via the cancel action
	if event.is_action_pressed("ui_cancel"):
		riddle_cancelled.emit()

func _on_submit_attempt() -> void:
	# Strip accidental trailing spaces and force uppercase to prevent dumb parsing bugs
	var player_input = code_input.text.strip_edges().to_upper()
	var clean_answer = correct_word.strip_edges().to_upper()
	
	if player_input == clean_answer:
		_handle_success()
	else:
		_handle_failure()

func _handle_success() -> void:
	# Disable inputs immediately to prevent double submissions
	code_input.editable = false
	submit_button.disabled = true
	
	feedback_label.text = "VAULT MECHANISM RELEASED. ACCESS GRANTED."
	feedback_label.add_theme_color_override("font_color", Color.GREEN)
	
	# Give the text a half-second beat to let the player read the success screen
	await get_tree().create_timer(1.5).timeout
	riddle_completed.emit()

func _handle_failure() -> void:
	feedback_label.text = "ERROR: INVALID OVERRIDE SEQUENCE."
	feedback_label.add_theme_color_override("font_color", Color.RED)
	
	# Clear out the wrong answer and juice the screen shake/visual fail state
	code_input.text = ""
	code_input.grab_focus()
