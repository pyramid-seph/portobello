extends Node2D


const SCORE_POINTS: int = 78


@export var speed: float = 48.0

var _direction: Vector2 = Vector2.LEFT
var _velocity: Vector2 = _direction * speed

@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var viewport_width: float = viewport_size.x
@onready var viewport_height: float = viewport_size.y
@onready var min_pos_x: float = 0.0
@onready var max_pos_x: float = viewport_width


func _process(delta: float) -> void:
	if position.x > max_pos_x or position.x < min_pos_x:
		_direction.x *= -1
		position.y += 30 + randi() % 10
	
	_velocity = _direction * speed
	position += _velocity * delta


func _correct_initial_pos_x() -> void:
	if not min_pos_x or not max_pos_x:
		return
	
	if position.x >= max_pos_x:
		_direction = Vector2.LEFT
	if position.x <= min_pos_x:
		_direction = Vector2.RIGHT
	
	position.x = clamp(position.x, min_pos_x, max_pos_x)
