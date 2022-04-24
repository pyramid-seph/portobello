extends Area2D

const SCORE_POINTS = 50

var _speed :=  32.0
var _direction := Vector2(1, 1)
var _velocity := _speed * _direction

onready var viewport_size = get_tree().get_root().get_viewport().size
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
		_velocity.x *= -1
	position += _velocity * delta


func _autoremove() -> void:
	if position.y > viewport_height:
		queue_free()
