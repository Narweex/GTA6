extends Control

@onready var game_timer: Timer = $GameTimer
@onready var clock_label: Label = $MarginContainer/TimeLabel
@onready var tick_audio: AudioStreamPlayer = $TickAudio


#seconds tracker
var last_tracked_second: int = -1

func _process(_delta: float) -> void:
	#get the remainig time from the GameTimer node
	var time_left: float = game_timer.time_left
	
	#split into minutes and seconds to display digits correctly
	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	
	var current_second: int = int(time_left)
	
	#this is for string formatting 
	clock_label.text = "%02d:%02d" % [minutes, seconds]

#play audio in the final 10 seconds perhaps
func play_countdown_tick() -> void:
	# Plays your clock audio stream instantly
	tick_audio.play()
func _on_game_timer_timeout() -> void:
	trigger_explosion_sequence()
		#trigger the explosion. This will be pain to code
	
func trigger_explosion_sequence() -> void:
	print("Boom wtf. This still needs to be scripted")
	
