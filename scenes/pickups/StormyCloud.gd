extends Area2D

const SCORE_POINTS = 50
const SPEED = 48
const DIRECTION = Vector2.DOWN
const VELOCITY = SPEED * DIRECTION

onready var animated_sprite = $AnimatedSprite
onready var viewport_size = get_viewport_rect().size
onready var viewport_height = viewport_size.y


func _ready() -> void:
	var frames_count = animated_sprite.frames.get_frame_count("default")
	animated_sprite.frame = randi() % frames_count
	animated_sprite.play()


func _process(delta) -> void:
	_move(delta)
	_autoremove()


func _move(delta) -> void:
	position += VELOCITY * delta


func _autoremove() -> void:
	if position.y >= viewport_height:
		queue_free()


func pick_up() -> void:
	PlayerData.score += SCORE_POINTS
	PlayerData.power_up_count += 1
	queue_free()
