# interaction_prompt.gd
extends Control
@onready var label: Label = $InteractionLabel

func _ready() -> void:
	hide_prompt() #hidden initially

func show_prompt(text: String = "Press [E] to Interact") -> void:
	label.text = text
	visible = true

func hide_prompt() -> void:
	visible = false
