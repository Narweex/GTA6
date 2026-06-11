extends Control

signal riddle_completed
signal riddle_cancelled

@export var hint_text: String = "Connect the correct color cables to repair the generator"

@onready var left_vbox: VBoxContainer = $HBoxContainer/LeftWiresContainer
@onready var right_vbox: VBoxContainer = $HBoxContainer/RightWiresContainer
@onready var active_line: Line2D = $ActiveLine
@onready var completed_lines: Node = $CompletedLines
@onready var hint_label: Label = $HintLabel 

var colors: Array[Color] = [
	Color("ff3333"), # Red
	Color("33cc33"), # Green
	Color("3366ff"), # Blue
	Color("ffcc00"), # Yellow
	Color("ff6600")  # Orange
]

var is_dragging: bool = false
var current_start_node: Panel = null
var hovered_right_node: Panel = null
var completed_connections: int = 0

func _ready() -> void:
	# Add an industrial terminal glow to our active draw line
	active_line.width = 10
	active_line.antialiased = true
	active_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	active_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	active_line.hide()
	
	if hint_label:
		hint_label.text = hint_text
	
	_setup_terminals(left_vbox, true)
	_setup_terminals(right_vbox, false)

func _process(_delta: float) -> void:
	if is_dragging:
		# Draw perfectly from the center of the grabbed wire to the current mouse point
		active_line.set_point_position(1, get_local_mouse_position())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		riddle_cancelled.emit()
		
	# FIX #2: Global Mouse-Up Protection. 
	# Catches the drop event even if the cursor is flying across the screen at 100mph.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			_evaluate_connection_drop()

func _setup_terminals(vbox: VBoxContainer, is_left: bool) -> void:
	var shuffled_colors = colors.duplicate()
	shuffled_colors.shuffle()

	for i in range(colors.size()):
		var socket = _create_industrial_socket(shuffled_colors[i])

		if is_left:
			# Left sockets track hover indicators and initialization clicks
			socket.gui_input.connect(_on_left_gui_input.bind(socket))
			socket.mouse_entered.connect(_on_socket_hover_entered.bind(socket))
			socket.mouse_exited.connect(_on_socket_hover_exited.bind(socket))
		else:
			# Right sockets track dynamic alignment zones
			socket.mouse_entered.connect(_on_right_mouse_entered.bind(socket))
			socket.mouse_exited.connect(_on_right_mouse_exited.bind(socket))

		vbox.add_child(socket)

func _create_industrial_socket(wire_color: Color) -> Panel:
	var base_panel = Panel.new()
	base_panel.custom_minimum_size = Vector2(60, 60) # Slightly bumped up target for easier grabbing
	base_panel.pivot_offset = Vector2(30, 30)
	
	# Outer Metallic Ring Frame
	var outer_style = StyleBoxFlat.new()
	outer_style.bg_color = Color("1e1e22") 
	outer_style.set_border_width_all(4)
	outer_style.border_color = Color("4b4b54") 
	outer_style.set_corner_radius_all(100) 
	base_panel.add_theme_stylebox_override("panel", outer_style)
	
	# Inner Core Color Node
	var core = Panel.new()
	core.custom_minimum_size = Vector2(24, 24)
	core.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var core_style = StyleBoxFlat.new()
	core_style.bg_color = wire_color
	core_style.set_corner_radius_all(100)
	core.add_theme_stylebox_override("panel", core_style)
	
	# FIX #1: Stop child containers from stealing input flags from the mouse collision check!
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	base_panel.set_meta("wire_color", wire_color)
	base_panel.add_child(core)
	
	return base_panel

func _on_left_gui_input(event: InputEvent, terminal: Panel) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_dragging = true
		current_start_node = terminal

		active_line.default_color = terminal.get_meta("wire_color")
		active_line.clear_points()

		# FIX #1: Container-proof positioning using global-to-local translation
		var global_center = terminal.global_position + (terminal.size / 2)
		var local_start = get_global_transform().affine_inverse() * global_center
		
		active_line.add_point(local_start)
		active_line.add_point(get_local_mouse_position())
		active_line.show()
		
		terminal.scale = Vector2(0.9, 0.9)

func _evaluate_connection_drop() -> void:
	# FIX #2: Take immediate snapshots of your nodes. Even if mouse signals
	# clear the global variables mid-frame, these local variables stay safe!
	var start_node = current_start_node
	var end_node = hovered_right_node

	is_dragging = false
	active_line.hide()
	
	if start_node:
		start_node.scale = Vector2(1.0, 1.0)

	if start_node and end_node:
		if end_node.get_meta("wire_color") == start_node.get_meta("wire_color"):
			# Run the connection using our safe snapshots
			_create_permanent_line(start_node, end_node)
			
			start_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			end_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			start_node.modulate = Color(0.5, 0.5, 0.5, 0.8)
			end_node.modulate = Color(0.5, 0.5, 0.5, 0.8)
			end_node.scale = Vector2(1.0, 1.0)
		else:
			_trigger_socket_shake(start_node)
	
	current_start_node = null

func _on_socket_hover_entered(terminal: Panel) -> void:
	terminal.scale = Vector2(1.15, 1.15)
	var style = terminal.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		style.border_color = terminal.get_meta("wire_color")

func _on_socket_hover_exited(terminal: Panel) -> void:
	terminal.scale = Vector2(1.0, 1.0)
	var style = terminal.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		style.border_color = Color("4b4b54")

func _on_right_mouse_entered(terminal: Panel) -> void:
	hovered_right_node = terminal
	terminal.scale = Vector2(1.2, 1.2)
	if is_dragging and current_start_node:
		var style = terminal.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			style.border_color = current_start_node.get_meta("wire_color")

func _on_right_mouse_exited(terminal: Panel) -> void:
	if hovered_right_node == terminal:
		hovered_right_node = null
	terminal.scale = Vector2(1.0, 1.0)
	var style = terminal.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		style.border_color = Color("4b4b54")

func _create_permanent_line(start_node: Panel, end_node: Panel) -> void:
	var new_line = Line2D.new()
	new_line.width = 10
	new_line.default_color = start_node.get_meta("wire_color")
	new_line.antialiased = true
	new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	var start_center = start_node.global_position + (start_node.size / 2)
	var end_center = end_node.global_position + (end_node.size / 2)
	var inv_transform = get_global_transform().affine_inverse()

	new_line.add_point(inv_transform * start_center)
	new_line.add_point(inv_transform * end_center)
	
	completed_lines.add_child(new_line)
	completed_connections += 1
	
	if completed_connections == colors.size():
		_all_wires_connected()

func _trigger_socket_shake(terminal: Panel) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(terminal, "position:x", terminal.position.x + 6, 0.05)
	tween.tween_property(terminal, "position:x", terminal.position.x - 6, 0.05)
	tween.tween_property(terminal, "position:x", terminal.position.x, 0.05)


func _all_wires_connected() -> void:
	if hint_label:
		hint_label.text = "GENERATOR POWER RESTORED"
		hint_label.add_theme_color_override("font_color", Color.GREEN)
		
	await get_tree().create_timer(1.0).timeout
	riddle_completed.emit()
