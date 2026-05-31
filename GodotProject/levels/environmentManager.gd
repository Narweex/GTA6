extends Node3D 

func _ready() -> void:
	Progression.riddle_completed.connect(_on_riddle_solved)
	##check for an already completed tutorial riddle
	if Progression.riddles.get("cable_hex", false) == true:
		_turn_on_lights(true) 

func _on_riddle_solved(riddle_id: String) -> void:
	#if the player solved the generator riddle, turn on the lights
	if riddle_id == "cable_hex":
		_turn_on_lights(false) 

func _turn_on_lights(instant: bool) -> void:
	var lights = get_tree().get_nodes_in_group("facility_lights")
	
	if instant:
		for light in lights:
			if light is Light3D:
				light.visible = true
	else:
		#let's add some flicker, it will be cool guys
		_dramatic_flicker(lights)

#okay I have no idea here. Gemini LLM generated this code
func _dramatic_flicker(lights: Array[Node]) -> void:
	var timer = get_tree().create_timer(0.1)
	
	#fast flicker
	_set_lights_visibility(lights, true)
	await get_tree().create_timer(0.15).timeout
	
	#quick blackout after flicker
	_set_lights_visibility(lights, false)
	await get_tree().create_timer(0.1).timeout
	
	#repeat the flicker
	_set_lights_visibility(lights, true)
	await get_tree().create_timer(0.2).timeout
	
	#last blackout
	_set_lights_visibility(lights, false)
	await get_tree().create_timer(0.05).timeout
	
	#leave the power finally on
	_set_lights_visibility(lights, true)
	print("Light were set visible")

func _set_lights_visibility(lights: Array[Node], is_visible: bool) -> void:
	for light in lights:
		if light is Light3D:
			light.visible = is_visible
