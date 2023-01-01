extends Area2D

const SCORE_POINTS = 50
const SPEED := 32.0
const DIRECTION := Vector2(1, 1)
const MIN_STAMINA := 5
const BASE_STAMINA := 20

var velocity: Vector2 = SPEED * DIRECTION

@onready var viewport_size = get_viewport_rect().size
@onready var viewport_width = viewport_size.x
@onready var viewport_height = viewport_size.y
@onready var sprite_width = $AnimatedSprite2D.frames.get_frame("default", 0).get_width()
@onready var min_pos_x = 0
@onready var max_pos_x = viewport_width - sprite_width


func _ready() -> void:
	if randi() % 2 == 0:
		velocity.x *= -1


func _process(delta) -> void:
	_move(delta)
	_autoremove()


func _move(delta) -> void:
	if position.x > max_pos_x or position.x < min_pos_x:
		velocity.x *= -1
	position += velocity * delta


func _autoremove() -> void:
	if position.y >= viewport_height:
		queue_free()


func pick_up(picker) -> void:
	if picker.has_method("add_points_to_score"):
		picker.add_points_to_score(SCORE_POINTS)
	if picker.has_method("add_stamina"):
		picker.add_stamina(randi() % BASE_STAMINA + MIN_STAMINA)
	queue_free()
