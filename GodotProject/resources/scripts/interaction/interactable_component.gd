class_name InteractableComponent
extends Node

## Emitted when the player interacts with this component
signal on_interact

func interact() -> void:
	on_interact.emit()
