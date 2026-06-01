extends Control

signal riddle_completed
signal riddle_cancelled

@export var hint_text: String = "WARNING: AUXILIARY POWER FAILURE. MATCH VOLTAGE FREQUENCIES TO REBOOT GENERATOR."

@onready var left_vbox: VBoxContainer = $HBoxContainer/LeftWiresContainer
@onready var right_vbox: VBoxContainer = $HBoxContainer/RightWiresContainer
@onready var active_line: Line2D = $ActiveLine
@onready var completed_lines: Node = $CompletedLines
@onready var hint_label: Label = $HintLabel 

# Industrial/Generator color palette (Solid electrical wire colors)
var colors: Array[Color] = [
	Color("ff3333"), # Red
	Color("33cc33"), # Green
	Color("3366ff"), # Blue
	Color("ffcc00"), # Yellow
	Color("ff6600")  
]

var is_dragging: bool = false
var current_start_node: Panel = null
var hovered_right_node: Panel = null
var completed_connections: int = 0

func _ready() -> void:
	active_line.width = 14
	active_line.antialiased = true
	active_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	active_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	if hint_label:
		hint_label.text = hint_text
	
	_setup_terminals(left_vbox, true)
	_setup_terminals(right_vbox, false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		riddle_cancelled.emit()

func _process(_delta: float) -> void:
	if is_dragging:
		active_line.set_point_position(1, get_local_mouse_position())

func _setup_terminals(vbox: VBoxContainer, is_left: bool) -> void:
	var shuffled_colors = colors.duplicate()
	shuffled_colors.shuffle()

	for i in range(colors.size()):
		var socket = _create_industrial_socket(shuffled_colors[i])

		if is_left:
			socket.gui_input.connect(_on_left_gui_input.bind(socket))
		else:
			socket.mouse_entered.connect(_on_right_mouse_entered.bind(socket))
			socket.mouse_exited.connect(_on_right_mouse_exited.bind(socket))

		vbox.add_child(socket)

# Procedurally creates a circular terminal lug/socket fitting a generator panel
func _create_industrial_socket(wire_color: Color) -> Panel:
	var base_panel = Panel.new()
	base_panel.custom_minimum_size = Vector2(55, 55)
	
	# 1. Outer Metallic Ring
	var outer_style = StyleBoxFlat.new()
	outer_style.bg_color = Color("2a2a2a") # Dark metallic gray housing
	outer_style.border_width_left = 4
	outer_style.border_width_top = 4
	outer_style.border_width_right = 4
	outer_style.border_width_bottom = 4
	outer_style.border_color = Color("555555") # Silver metallic rim
	outer_style.set_corner_radius_all(100) # Makes it perfectly circular
	base_panel.add_theme_stylebox_override("panel", outer_style)
	
	# 2. Inner Colored Connector Core
	var core = Panel.new()
	core.custom_minimum_size = Vector2(20, 20)
	core.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var core_style = StyleBoxFlat.new()
	core_style.bg_color = wire_color
	core_style.set_corner_radius_all(100)
	core.add_theme_stylebox_override("panel", core_style)
	
	# Metadata tag to verify connections instead of reading structural node color directly
	base_panel.set_meta("wire_color", wire_color)
	base_panel.add_child(core)
	
	return base_panel

func _on_left_gui_input(event: InputEvent, terminal: Panel) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			current_start_node = terminal
	
			active_line.default_color = terminal.get_meta("wire_color")
			active_line.clear_points()
	
			var start_pos = terminal.global_position + (terminal.size / 2)
			var local_start = get_global_transform().affine_inverse() * start_pos
			active_line.add_point(local_start)
			active_line.add_point(get_local_mouse_position())
			active_line.show()
			
		elif not event.pressed and is_dragging:
			is_dragging = false
			active_line.hide()

			if hovered_right_node != null and hovered_right_node.get_meta("wire_color") == terminal.get_meta("wire_color"):
				# FIX: Safe local snapshot before Godot's signal loop interferes
				var right_node = hovered_right_node
				
				_create_permanent_line(terminal, right_node)
				
				terminal.mouse_filter = Control.MOUSE_FILTER_IGNORE
				right_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				terminal.modulate = Color(0.6, 0.6, 0.6, 1.0)
				right_node.modulate = Color(0.6, 0.6, 0.6, 1.0)
				
func _on_right_mouse_entered(terminal: Panel) -> void:
	hovered_right_node = terminal
	# Subtle hover visual feedback
	terminal.scale = Vector2(1.1, 1.1)
	terminal.pivot_offset = terminal.size / 2

func _on_right_mouse_exited(terminal: Panel) -> void:
	if hovered_right_node == terminal:
		hovered_right_node = null
	terminal.scale = Vector2(1.0, 1.0)

func _create_permanent_line(start_node: Panel, end_node: Panel) -> void:
	var new_line = Line2D.new()
	new_line.width = 14
	new_line.default_color = start_node.get_meta("wire_color")
	new_line.antialiased = true
	new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	var start_pos = start_node.global_position + (start_node.size / 2)
	var end_pos = end_node.global_position + (end_node.size / 2)
	
	var UI_matrix = get_global_transform().affine_inverse()
	new_line.add_point(UI_matrix * start_pos)
	new_line.add_point(UI_matrix * end_pos)
	
	completed_lines.add_child(new_line)
	completed_connections += 1
	
	if completed_connections == colors.size():
		_all_wires_connected()

func _all_wires_connected() -> void:
	if hint_label:
		hint_label.text = "SYSTEM ONLINE. POWER RESTORED."
		hint_label.add_theme_color_override("font_color", Color.GREEN)
		
	await get_tree().create_timer(0.6).timeout
	riddle_completed.emit()
