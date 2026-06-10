extends CanvasLayer 

signal riddle_completed
signal riddle_cancelled

var kabel_szene = preload("res://levels/wire_riddle/kabel.tscn") 
var gesuchte_farbe : Color 


@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label
@onready var container: VBoxContainer = $Panel/VBoxContainer
@onready var time_penalty_label: Label = $TimePenalty

func _ready() -> void:
	
	visible = true
	if time_penalty_label:
		time_penalty_label.visible = false 
		
	generiere_raetsel()

func generiere_raetsel() -> void:
	if container == null: 
		push_error("VBoxContainer layout path is missing!")
		return
	
	
	for n in container.get_children():
		n.queue_free()
	
	var farb_liste = []
	for i in range(7):
		farb_liste.append(Color(randf(), randf(), randf()))
	
	gesuchte_farbe = farb_liste.pick_random()
	label.text = "find the right wire: #" + gesuchte_farbe.to_html(false)
	
	farb_liste.shuffle()
	
	for i in range(7):
		var neues_kabel = kabel_szene.instantiate()
		container.add_child(neues_kabel)
		
		var farbe = farb_liste[i]
		neues_kabel.setze_farbe(farbe)
		
		var wire_button = neues_kabel.get_node_or_null("Button")
		if wire_button:
			wire_button.pressed.connect(_on_kabel_pressed.bind(farbe))

func _on_kabel_pressed(farbe: Color) -> void:
	if farbe == gesuchte_farbe:
		print("Richtig! Puzzle solved.")
		riddle_completed.emit() 
	else:
		print("Falsche Farbe! Penalty applied.")
		
		var game_timer = get_node_or_null("/root/World/HUDLayer/HUD/GameTimer")
		if game_timer and game_timer is Timer:
			var neue_zeit = game_timer.time_left - 10.0
			if neue_zeit < 0: 
				neue_zeit = 0
			game_timer.start(neue_zeit)
		
		show_game_over_and_close()

func show_game_over_and_close() -> void:
	if time_penalty_label:
		time_penalty_label.visible = true
	await get_tree().create_timer(1.5).timeout
	if time_penalty_label:
		time_penalty_label.visible = false
		
	#riddle_cancelled.emit() 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and visible:
		riddle_cancelled.emit()
		get_viewport().set_input_as_handled()
