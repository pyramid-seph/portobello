extends AnimatedSprite2D


func _ready():
	set_frame(randi() % sprite_frames.get_frame_count("default"))
