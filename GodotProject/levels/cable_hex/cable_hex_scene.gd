extends Control

signal cable_hex_completed

@onready var left_vbox = $HBoxContainer/LeftWiresContainer
@onready var right_vbox = $HBoxContainer/RightWiresContainer
@onready var active_line = $ActiveLine
@onready var completed_lines = $CompletedLines

# Seznam barev, které chceme propojovat
var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PURPLE]

# Proměnné pro tažení myší
var is_dragging = false
var current_start_node = null
var hovered_right_node = null

var completed_connections = 0

func _ready():
	active_line.width = 12
	# Vygenerujeme terminály pro obě strany
	setup_terminals(left_vbox, true)
	setup_terminals(right_vbox, false)

func setup_terminals(vbox: VBoxContainer, is_left: bool):
	var shuffled_colors = colors.duplicate()
	shuffled_colors.shuffle() # Zamíchá barvy pro každý sloupec zvlášť

	for i in range(5):
		var terminal = ColorRect.new()
		terminal.custom_minimum_size = Vector2(50, 50)
		terminal.color = shuffled_colors[i]

		# Napojení signálů v závislosti na straně
		if is_left:
			# Levou stranu budeme "klikat a tahat"
			terminal.gui_input.connect(_on_left_gui_input.bind(terminal))
		else:
			# U pravé strany jen hlídáme, jestli nad ní jsme myší
			terminal.mouse_entered.connect(_on_right_mouse_entered.bind(terminal))
			terminal.mouse_exited.connect(_on_right_mouse_exited.bind(terminal))

		vbox.add_child(terminal)

func _on_left_gui_input(event: InputEvent, terminal: ColorRect):
	# Detekce stisknutí a puštění levého tlačítka myši
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 1. Začátek tažení kabelu
			is_dragging = true
			current_start_node = terminal
			active_line.default_color = terminal.color
			active_line.clear_points()
			
			# Startovní bod je střed stisknutého čtverce
			var start_pos = terminal.global_position + (terminal.size / 2)
			active_line.add_point(start_pos)
			active_line.add_point(get_global_mouse_position())
			active_line.show()
			
		elif not event.pressed and is_dragging:
			# 2. Puštění tlačítka myši
			is_dragging = false
			active_line.hide()

			# Zjistíme, jestli jsme kabel pustili nad správným pravým terminálem
			if hovered_right_node != null and hovered_right_node.color == terminal.color:
				create_permanent_line(terminal, hovered_right_node)
				# Vypneme interakci obou spojených konců, aby nešly spojit dvakrát
				terminal.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hovered_right_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_right_mouse_entered(terminal: ColorRect):
	hovered_right_node = terminal

func _on_right_mouse_exited(terminal: ColorRect):
	if hovered_right_node == terminal:
		hovered_right_node = null

func _process(delta):
	# Pokud zrovna táhneme kabel, neustále updatujeme jeho konec podle kurzoru
	if is_dragging:
		active_line.set_point_position(1, get_global_mouse_position())

func create_permanent_line(start_node: ColorRect, end_node: ColorRect):
	var new_line = Line2D.new()
	new_line.width = 12
	new_line.default_color = start_node.color
	
	# Body určíme opět jako středy obou UI uzlů
	new_line.add_point(start_node.global_position + (start_node.size / 2))
	new_line.add_point(end_node.global_position + (end_node.size / 2))
	
	completed_lines.add_child(new_line)
	
	completed_connections+= 1
	
	if completed_connections == colors.size():
		all_wires_connected()


func all_wires_connected():
	# Volitelná krátká pauza (0.4 vteřiny), aby hráč viděl, že spojil poslední kabel
	await get_tree().create_timer(0.4).timeout
	
	# Vyemitujeme (vyhlásíme) signál do okolí
	cable_hex_completed.emit()
	
