extends Control

@onready var game_timer: Timer = $GameTimer
@onready var clock_label: Label = $MarginContainer/ClockLabel

func _process(_delta: float) -> void:
	#get the remainig time from the GameTimer node
	var time_left: float = game_timer.time_left
	
	#split into minutes and seconds to display digits correctly
	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	
	#this is for string formatting 
	clock_label.text = "%02d:%02d" % [minutes, seconds]
	
func _on_game_timer_timeout() -> void:
	trigger_explosion_sequence()
		#trigger the explosion. This will be pain to code
	
func trigger_explosion_sequence() -> void:
	print("Boom wtf. This still needs to be scripted")
	
