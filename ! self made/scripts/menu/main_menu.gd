extends Control

func on_start_button_pressed():
	#execute the game scene
	get_tree().change_scene_to_file("res://! self made/scenes/menu/game.tscn")
	
func on_quit_button_pressed():
	get_tree().quit(0)
	

@export var target_alpha = 1.0
@export var target_alpha2 = 0.8
func _process(delta):	
	if randf() < 0.5:
		target_alpha2 = randf_range(0.3, 0.9)
		target_alpha = randf_range(0.3, 0.9)
		$VBoxContainer/StartButton.modulate.a = lerp($VBoxContainer/StartButton.modulate.a, target_alpha, 0.2)
		$VBoxContainer/QuitButton.modulate.a = lerp($VBoxContainer/QuitButton.modulate.a, target_alpha2, 0.2)
		$VBoxContainer2/RichTextLabel.modulate.a = lerp($VBoxContainer2/RichTextLabel.modulate.a, target_alpha2, 0.2)
		$VBoxContainer/StartButton.position.x += randf_range(-0.2, 0.2)
