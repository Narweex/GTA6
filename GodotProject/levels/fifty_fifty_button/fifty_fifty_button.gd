extends Control

signal minigame_won
signal minigame_lost

@onready var button_left = $HBoxContainer/LeftButton
@onready var button_right = $HBoxContainer/RightButton
# Přidáme odkaz na náš nový textový uzel
@onready var result_label = $ResultLabel 

var winning_button_index: int

func _ready():
	winning_button_index = randi() % 2
	
	button_left.pressed.connect(_on_button_pressed.bind(0))
	button_right.pressed.connect(_on_button_pressed.bind(1))
	
	# Ujistíme se, že na začátku hry je text prázdný
	result_label.text = ""

func _on_button_pressed(clicked_button_index: int):
	# 1. Deaktivace tlačítek
	button_left.disabled = true
	button_right.disabled = true
	
	# 2. Vypsání hlášky a případná změna barvy
	if clicked_button_index == winning_button_index:
		result_label.text = "You won!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		result_label.text = "You lost!"
		result_label.add_theme_color_override("font_color", Color.RED)
	
	# 3. Prodloužená pauza, aby si hráč mohl hlášku přečíst (např. 1.5 vteřiny)
	await get_tree().create_timer(1.5).timeout
	
	# 4. Vyhodnocení a odeslání signálu do hlavní hry až PO přečtení
	if clicked_button_index == winning_button_index:
		minigame_won.emit()
	else:
		minigame_lost.emit()
