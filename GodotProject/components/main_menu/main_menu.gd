extends Control

@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var main_theme: AudioStreamPlayer = $MainTheme
@export_file("*.tscn") var game_scene_path: String = "res://levels/game.tscn"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	main_theme.play()
	if high_score_label:
		high_score_label.text = "HIGHEST SCORE: " + str(Progression.high_score)
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)
	
func _launch_challenge_mode() -> void:
	Progression.challenge_mode = true
	get_tree().change_scene_to_file(game_scene_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
