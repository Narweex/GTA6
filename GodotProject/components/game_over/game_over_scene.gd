extends Control

@onready var main_theme: AudioStreamPlayer = $MainTheme
@export_file("*.tscn") var game_scene_path: String = "res://levels/game.tscn"
@export_file("*.tscn") var main_menu_scene_path: String = "res://components/main_menu/main_menu.tscn"

func _ready():
	main_theme.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_main_menu_button_pressed() -> void:
	# Clean up progression states even if they head back to the main menu
	if Progression.has_method("reset_game"):
		Progression.reset_game()
		
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene_path)
