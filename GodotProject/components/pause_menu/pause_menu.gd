extends Control
#since gettree.paused freezes every node in the project we need to make an exclusion for this particular node
#thus the process mode needs to be set to WHen paused or Always

func _ready():
	# Menü beim Start unsichtbar machen
	#i do not understand anything but i changed it to the hide method 
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):#UI cancel is the shortcut for the esc key
		#godot is so goofy
		toggle_pause()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	
	if new_pause_state:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_continue_pressed() -> void:
	toggle_pause()
	
	#get out tof the game
func _on_quit_button_pressed() -> void:
	#we need to unpause when changing scenes
	get_tree().paused = false
	get_tree().change_scene_to_file("res://components/main_menu/main_menu.tscn")
