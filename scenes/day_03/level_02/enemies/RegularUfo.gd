extends Area2D
class_name Drone

const SCORE_POINTS_GUN: int = 10
const SCORE_POINTS_MEGA_GUN: int = 5

enum MovementPattern {
	VERTICAL_DOWN,
	VERTICAL_UP,
	HORIZONTAL_RIGHT,
	HORIZONTAL_LEFT,
	SQUARE_UP,
	SQUARE_DOWN,
	ZIG_ZAG_DOWN,
}

@export var Explosion: PackedScene
@export var speed: float = 87.5
@export var movement_pattern: MovementPattern = MovementPattern.VERTICAL_DOWN:
	get:
		return movement_pattern
	set(mod_value):
		movement_pattern = mod_value
		match (movement_pattern):
			MovementPattern.VERTICAL_DOWN:
				_direction = Vector2.DOWN
			MovementPattern.VERTICAL_UP:
				_direction = Vector2.UP
			MovementPattern.HORIZONTAL_LEFT:
				_direction = Vector2.LEFT
			MovementPattern.HORIZONTAL_RIGHT:
				_direction = Vector2.RIGHT
			MovementPattern.ZIG_ZAG_DOWN:
				_direction = Vector2(1, 1)
			MovementPattern.SQUARE_UP:
				_direction = Vector2.RIGHT
			MovementPattern.SQUARE_DOWN:
				_direction = Vector2.LEFT
			_:
				print_debug("Unknown movement pattern: %s. Will default to VERTICAL_DOWN." % str(mod_value))
				movement_pattern = MovementPattern.VERTICAL_DOWN
				_direction = Vector2.DOWN
		_correct_initial_pos_x()
var world: Node2D:
	set(value):
		world = value
		if not _is_ready: return
		_gun.world = value

var _direction: Vector2 = Vector2.DOWN
var _velocity: Vector2 = _direction * speed

@onready var _gun := $Gun
@onready var _viewport_size: Vector2 = get_viewport_rect().size
@onready var _viewport_width: float = _viewport_size.x
@onready var _viewport_height: float = _viewport_size.y
@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _sprite_width: float = _animated_sprite.sprite_frames.get_frame_texture("default", 0).get_width()
@onready var _min_pos_x: float = 0.0
@onready var _max_pos_x: float = _viewport_width - _sprite_width
@onready var _is_ready: bool = true


func _ready() -> void:
	_correct_initial_pos_x()


func _process(delta: float) -> void:
	match (movement_pattern):
		MovementPattern.ZIG_ZAG_DOWN:
			if position.x > _max_pos_x or position.x < _min_pos_x:
				_direction.x *= -1
		MovementPattern.SQUARE_UP:
			if position.x > _max_pos_x or position.x < _min_pos_x:
				_direction.x *= -1
				position.y -= 30 + randi() % 10
		MovementPattern.SQUARE_DOWN:
			if position.x > _max_pos_x or position.x < _min_pos_x:
				_direction.x *= -1
				position.y += 30 + randi() % 10
	
	_velocity = _direction * speed
	position += _velocity * delta


func shoot() -> bool:
	return _gun.shoot(Vector2.DOWN)


func kill(killer: Node, killed_by_mega_gun: bool = false) -> void:
	if killer and killer.has_method("add_points_to_score"):
		killer.add_points_to_score(
			SCORE_POINTS_MEGA_GUN if killed_by_mega_gun else SCORE_POINTS_GUN
		)
	explode()


func explode() -> void:
	var explosion = Explosion.instantiate()
	explosion.centered = _animated_sprite.centered
	explosion.global_position = global_position
	_world_or_default().add_child(explosion)
	queue_free()


func _world_or_default() -> Node2D:
	if world:
		return world
	elif owner and owner.get_parent():
		return owner.get_parent()
	else:
		return get_node("/root")


func _correct_initial_pos_x() -> void:
	if not _is_ready: return
	
	match (movement_pattern):
		MovementPattern.SQUARE_UP, MovementPattern.SQUARE_DOWN:
			if position.x >= _max_pos_x:
				_direction = Vector2.LEFT
			if position.x <= _min_pos_x:
				_direction = Vector2.RIGHT
	position.x = clamp(position.x, _min_pos_x, _max_pos_x)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	var killer = area.shooter if area.is_in_group("bullets") else area
	kill(killer)