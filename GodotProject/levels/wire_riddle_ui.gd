extends CanvasLayer


signal raetsel_geloest

var kabel_szene = preload("res://levels/Wire_puzzle/kabel.tscn") 
var gesuchte_farbe : Color 

func _ready():
	self.visible = false
	$TimePenalty.visible = false 
	generiere_raetsel()

func generiere_raetsel():
	var panel = $Panel
	var container = panel.get_node_or_null("VBoxContainer") 
	if container == null: return
	
	for n in container.get_children():
		n.queue_free()
	
	var farb_liste = []
	for i in range(7):
		farb_liste.append(Color(randf(), randf(), randf()))
	
	gesuchte_farbe = farb_liste.pick_random()
	$Panel/Label.text = "find the right wire: #" + gesuchte_farbe.to_html(false)
	
	farb_liste.shuffle()
	
	for i in range(7):
		var neues_kabel = kabel_szene.instantiate()
		container.add_child(neues_kabel)
		
		var farbe = farb_liste[i]
		neues_kabel.setze_farbe(farbe)
		
		if neues_kabel.has_node("Button"):
			neues_kabel.get_node("Button").pressed.connect(_on_kabel_pressed.bind(farbe))

func _on_kabel_pressed(farbe):
	var ziel_hex = $Panel/Label.text.replace("Finde Farbe: #", "")
	var kabel_hex = farbe.to_html(false)
	
	if kabel_hex == ziel_hex:
		print("Richtig! Signal wird gesendet.")
		raetsel_geloest.emit()
		close_riddle()
	else:
		print("Falsche Farbe! Zeitstrafe.")
		
		
		var game_timer = get_node_or_null("/root/World/HUDLayer/HUD/GameTimer")
		
		if game_timer:
			
			var neue_zeit = game_timer.time_left - 10.0
			
			
			if neue_zeit < 0: neue_zeit = 0
			
			
			game_timer.start(neue_zeit)
			print("Timer wurde aktualisiert auf: ", neue_zeit)
		else:
			print("FEHLER: GameTimer nicht gefunden!")
		
		show_game_over_and_close()

func show_game_over_and_close():
	var game_over_label = $TimePenalty
	game_over_label.visible = true
	await get_tree().create_timer(1.5).timeout
	game_over_label.visible = false
	close_riddle() 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and self.visible:
		close_riddle()
		get_viewport().set_input_as_handled()

func close_riddle() -> void:
	self.visible = false
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
