extends Control

@export_category("Tutorial Settings")
@export_file("*.tscn") var tutorial_scene_path: String = "res://levels/tutorial/TutorialScene.tscn"

@export_category("Scene Nodes")
@onready var game_timer: Timer = $GameTimer
@onready var clock_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var tick_audio: AudioStreamPlayer = $TickAudio

# Seconds tracker used to prevent audio looping infinitely on a single frame
var last_tracked_second: int = -1

func _ready() -> void:
	# 1. Instantly freeze the match environment so physics and countdowns don't run
	get_tree().paused = true
	
	# 2. Spawn and overlay the 2D tutorial screen over the player viewport
	var tutorial_resource = load(tutorial_scene_path)
	if tutorial_resource:
		var tutorial_instance = tutorial_resource.instantiate()
		
		# Connect the tutorial's close event directly to our countdown activation function
		tutorial_instance.tutorial_closed.connect(_start_gameplay_countdown)
		
		get_tree().root.add_child(tutorial_instance)
	else:
		# Fallback safety: if the tutorial asset file goes missing, don't softlock the game
		get_tree().paused = false
		game_timer.start()

func _process(_delta: float) -> void:
	# Get the remaining time from the GameTimer node
	var time_left: float = game_timer.time_left
	
	# Split into minutes and seconds to display digits correctly
	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	var current_second: int = int(time_left)
	
	# String formatting to pad zeros (e.g., "05:09")
	clock_label.text = "%02d:%02d" % [minutes, seconds]
	
	# --- panicking countdown ticks ---
	# If time is running out (10 seconds or lower) and we transition into a brand-new integer second
	if current_second <= 10 and current_second > 0:
		if current_second != last_tracked_second:
			last_tracked_second = current_second
			play_countdown_tick()

func play_countdown_tick() -> void:
	if tick_audio:
		tick_audio.play()

func _start_gameplay_countdown() -> void:
	# Unfreeze physics, movement, and standard frame execution loops
	get_tree().paused = false
	
	# Start the core match timer!
	if game_timer:
		game_timer.start()

func _on_game_timer_timeout() -> void:
	Progression.facility_detonated.emit()
