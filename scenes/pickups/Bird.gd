extends Area2D

const SCORE_POINTS = 50
const SPEED := 32.0
const DIRECTION := Vector2(1, 1)
const VELOCITY := SPEED * DIRECTION

onready var viewport_size = get_viewport_rect().size
onready var viewport_width = viewport_size.x
onready var viewport_height = viewport_size.y
onready var sprite_width = $AnimatedSprite.frames.get_frame("default", 0).get_width()
onready var min_pos_x = 0
onready var max_pos_x = viewport_width - sprite_width


func _process(delta) -> void:
	_move(delta)
	_autoremove()


func _move(delta) -> void:
	if position.x > max_pos_x or position.x < min_pos_x:
		VELOCITY.x *= -1
	position += VELOCITY * delta


func _autoremove() -> void:
	if position.y >= viewport_height:
		queue_free()


func pick_up(picker) -> void:
	if picker.is_in_group("players"):
		picker.add_points_to_score(SCORE_POINTS)
		picker.add_stamina(randi() % 20 + 5)
	queue_free()
