extends Control

@export_category("Tutorial Settings")
@export_file("*.tscn") var tutorial_scene_path: String = "res://levels/tutorial/TutorialScene.tscn"
@onready var current_score: Label = $CurrentScore
@export_category("Scene Nodes")
@onready var game_timer: Timer = $GameTimer
@onready var clock_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var tick_audio: AudioStreamPlayer = $TickAudio

var last_tracked_second: int = -1

func _ready() -> void:
	get_tree().paused = true
	
	var tutorial_resource = load(tutorial_scene_path)
	if tutorial_resource:
		var tutorial_instance = tutorial_resource.instantiate()
		tutorial_instance.tutorial_closed.connect(_start_gameplay_countdown)
		get_tree().root.add_child(tutorial_instance)
	else:
		_start_gameplay_countdown()


func _start_gameplay_countdown() -> void:
	get_tree().paused = false
	
	if Progression.challenge_mode:
		game_timer.wait_time = game_timer.wait_time * 0.6
	game_timer.start()

func _process(_delta: float) -> void:
	# keep checking the current score
	if current_score:
		current_score.text = "CURRENT SCORE: " + str(Progression.current_score)
	var time_left: float = game_timer.time_left
	
	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	var current_second: int = int(time_left)
	
	clock_label.text = "%02d:%02d" % [minutes, seconds]
	
	#not implemented
	if current_second <= 10 and current_second > 0:
		if current_second != last_tracked_second:
			last_tracked_second = current_second
			play_countdown_tick()

func play_countdown_tick() -> void:
	if tick_audio:
		tick_audio.play()

func _on_game_timer_timeout() -> void:
	Progression.facility_detonated.emit()
