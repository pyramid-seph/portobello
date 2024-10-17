extends Sprite2D


func _ready() -> void:
	flip_h = randi_range(0, 1) == 1
	flip_v = randi_range(0, 1) == 1
