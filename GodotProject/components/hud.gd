extends CanvasLayer

@onready var stage_label: Label = $MarginContainer/StageLabel

func _ready() -> void:
	Progression.stage_changed.connect(_on_game_stage_changed)
	
	stage_label.text = Progression.get_current_stage_text()

#start every time complete_riddle() == TRUE
func _on_game_stage_changed(new_stage_text: String) -> void:
	stage_label.text = new_stage_text
	
	#efect of change
	var tween = create_tween()
	stage_label.modulate = Color.RED # Text zčervená
	tween.tween_property(stage_label, "modulate", Color.WHITE, 0.5) # Během půl vteřiny se vrátí do normálu
