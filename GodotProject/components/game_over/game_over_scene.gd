extends Control

@onready var main_theme: AudioStreamPlayer = $MainTheme
@export_file("*.tscn") var game_scene_path: String = "res://levels/game.tscn"
@export_file("*.tscn") var main_menu_scene_path: String = "res://components/main_menu/main_menu.gd"

func _ready():
	main_theme.play()
	
func _on_repeat_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)


func _on_restart_button_pressed() -> void:
	pass # Replace with function body.
