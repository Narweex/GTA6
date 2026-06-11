extends Control

@onready var label: Label = $InteractionLabel

func _ready() -> void:
	hide_prompt() 

func show_prompt(text: String = "Press [E] to Interact") -> void:
	if Progression.is_minigame_active:
		hide_prompt()
		return
		
	label.text = text
	visible = true

func hide_prompt() -> void:
	visible = false
