extends AnimatedSprite2D


func _ready():
	set_frame(randi() % frames.get_frame_count("default"))
