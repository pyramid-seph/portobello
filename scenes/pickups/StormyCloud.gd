extends Area2D


const SPEED = 48
const SCORE = 50
const DIRECTION = Vector2.DOWN 


func _ready():
	var frames_count = $AnimatedSprite.frames.get_frame_count("default")
	$AnimatedSprite.frame = randi() % frames_count
	$AnimatedSprite.play()


func _process(delta):
	position += DIRECTION * SPEED * delta


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()


func _on_area_entered(_area):
	PlayerData.score += SCORE
	queue_free()
