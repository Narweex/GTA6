extends Label

# @onready var stage_label: Label = $MarginContainer/StageLabel

func _ready() -> void:
	Progression.stage_changed.connect(_on_game_stage_changed)
	
	text = Progression.get_current_stage_text()

#start every time complete_riddle() == TRUE
func _on_game_stage_changed(new_stage_text: String) -> void:
	text = new_stage_text
	
	#efect of change
	var tween = create_tween()
	modulate = Color.RED 
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
