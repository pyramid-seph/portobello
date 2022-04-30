extends AnimatedSprite


func _ready():
	set_frame(randi() % frames.get_frame_count("default"))
