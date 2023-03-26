class_name SimpleMover
extends Node


enum Pattern {
	NONE,
	VERTICAL_DOWN,
	VERTICAL_UP,
	HORIZONTAL_RIGHT,
	HORIZONTAL_LEFT,
	SQUARE_UP,
	SQUARE_DOWN,
	ZIG_ZAG_DOWN,
}

var speed: float = 0.0
var min_pos_x: float = 0.0
var max_pos_x: float = 0.0
var pattern := Pattern.NONE:
	set(value):
		pattern = value
		match (pattern):
			Pattern.VERTICAL_DOWN:
				_direction = Vector2.DOWN
			Pattern.VERTICAL_UP:
				_direction = Vector2.UP
			Pattern.HORIZONTAL_LEFT:
				_direction = Vector2.LEFT
			Pattern.HORIZONTAL_RIGHT:
				_direction = Vector2.RIGHT
			Pattern.ZIG_ZAG_DOWN:
				_direction = Vector2(1, 1)
			Pattern.SQUARE_UP:
				_direction = Vector2.RIGHT
			Pattern.SQUARE_DOWN:
				_direction = Vector2.LEFT
			_:
				_direction = Vector2.ZERO
		_ensure_correct_pos_x()

var _direction := Vector2.ZERO
var _velocity: Vector2 = _direction * speed


func _ready() -> void:
	await get_parent().ready
	_ensure_correct_pos_x()


func _process(delta: float) -> void:
	var curr_pos = _get_parent_positon()
	match (pattern):
		Pattern.ZIG_ZAG_DOWN:
			if curr_pos.x > max_pos_x or curr_pos.x < min_pos_x:
				_direction.x *= -1
		Pattern.SQUARE_UP:
			if curr_pos.x > max_pos_x or curr_pos.x < min_pos_x:
				_direction.x *= -1
				curr_pos.y -= 30 + randi() % 10
		Pattern.SQUARE_DOWN:
			if curr_pos.x > max_pos_x or curr_pos.x < min_pos_x:
				_direction.x *= -1
				curr_pos.y += 30 + randi() % 10
	_velocity = _direction * speed
	_set_parent_positon(curr_pos + _velocity * delta)


func _get_parent_positon() -> Vector2:
	return get_parent().position


func _set_parent_positon(position: Vector2) -> void:
	get_parent().position = position


func _ensure_correct_pos_x() -> void:
	var curr_pos = _get_parent_positon()
	match (pattern):
		Pattern.SQUARE_UP, Pattern.SQUARE_DOWN:
			if curr_pos.x >= max_pos_x:
				_direction = Vector2.LEFT
			if curr_pos.x <= min_pos_x:
				_direction = Vector2.RIGHT
	curr_pos.x = clamp(curr_pos.x, min_pos_x, max_pos_x)
	_set_parent_positon(curr_pos)
