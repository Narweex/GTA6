extends MeshInstance3D

var key_positions: Array = [
	Vector3(60.954, -1.693, 21.235),
	Vector3(58.703, -1.7, 26.155),
	Vector3(57.211, -1.703, 23.457),
	Vector3(59.731, -1.676, 25.189),
	Vector3(57.5, -1.701, 18.603)
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#randomly hide the key inside the storage room
	if not key_positions.is_empty():
		position = key_positions.pick_random()
