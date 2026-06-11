extends Control

@export_category("Tutorial Settings")
@export_file("*.tscn") var tutorial_scene_path: String = "res://levels/tutorial/TutorialScene.tscn"

@export_category("Scene Nodes")
@onready var current_score: Label = $CurrentScore
@onready var game_timer: Timer = $GameTimer
@onready var clock_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var tick_audio: AudioStreamPlayer = $TickAudio
@onready var battery_bar: ProgressBar = $VBoxContainer/BatteryBar

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
	
	
		
	var calculated_lifespan = game_timer.wait_time * 0.75
	
	if Progression.challenge_mode:
		game_timer.wait_time = game_timer.wait_time * 0.8
		calculated_lifespan = calculated_lifespan * 0.6
	Progression.max_battery = calculated_lifespan
	Progression.flashlight_battery = calculated_lifespan
	
	if battery_bar:
		battery_bar.max_value = Progression.max_battery
		battery_bar.value = Progression.flashlight_battery
	
	# 4. Kick off the level match clock
	game_timer.start()


func _process(_delta: float) -> void:
	# Keep checking the current score array metric
	if current_score:
		current_score.text = "CURRENT SCORE: " + str(Progression.current_score)
		
	# --- VISUAL BATTERY UPDATE ---
	# Continually drop the UI container bar fill to trace flashlight depletion frames
	if battery_bar:
		battery_bar.value = Progression.flashlight_battery
		
	var time_left: float = game_timer.time_left
	
	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	var current_second: int = int(time_left)
	
	clock_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Emergency ticking logic under 10 seconds
	if current_second <= 10 and current_second > 0:
		if current_second != last_tracked_second:
			last_tracked_second = current_second
			play_countdown_tick()


func play_countdown_tick() -> void:
	if tick_audio:
		tick_audio.play()


func _on_game_timer_timeout() -> void:
	Progression.facility_detonated.emit()
