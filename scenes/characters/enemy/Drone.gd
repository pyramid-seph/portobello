extends Area2D
class_name Drone

const SCORE_POINTS: int = 10
const DIRECTION := Vector2(1, 1)

enum MovementPattern {
	VERTICAL_DOWN,
	VERTICAL_UP,
	HORIZONTAL_RIGHT,
	HORIZONTAL_LEFT,
	SQUARE_UP,
	SQUARE_DOWN,
	ZIG_ZAG_DOWN
}

export var speed: float = 48.0
export(PackedScene) var explosion: PackedScene = preload("res://scenes/objects/Explosion.tscn")
export(MovementPattern) var movement_pattern = MovementPattern.VERTICAL_DOWN setget set_movement_pattern

var _direction: Vector2 = Vector2.DOWN
var _velocity = _direction * speed

onready var gun := $Gun
onready var world = get_parent()
onready var viewport_size = get_viewport_rect().size
onready var viewport_width = viewport_size.x
onready var viewport_height = viewport_size.y
onready var animated_sprite = $AnimatedSprite
onready var sprite_width = animated_sprite.frames.get_frame("default", 0).get_width()
onready var min_pos_x = 0
onready var max_pos_x = viewport_width - sprite_width


func _ready():
	_correct_initial_pos_x()


func _process(delta: float) -> void:
	match (movement_pattern):
		MovementPattern.ZIG_ZAG_DOWN:
			if position.x > max_pos_x or position.x < min_pos_x:
				_direction.x *= -1
		MovementPattern.SQUARE_UP:
			if position.x > max_pos_x or position.x < min_pos_x:
				_direction.x *= -1
				position.y -= 30 + randi() % 10
		MovementPattern.SQUARE_DOWN:
			if position.x > max_pos_x or position.x < min_pos_x:
				_direction.x *= -1
				position.y += 30 + randi() % 10
	
	_velocity = _direction * speed
	position += _velocity * delta


func shoot() -> bool:
	return gun.shoot(Vector2.DOWN)


func explode() -> void:
	var new_explosion = explosion.instance()
	new_explosion.centered = animated_sprite.centered
	new_explosion.global_position = global_position
	world.add_child(new_explosion)
	queue_free()


func kill(killer: Node) -> void:
	if killer and killer.has_method("add_points_to_score"):
		killer.add_points_to_score(SCORE_POINTS)
	explode()


func _correct_initial_pos_x():
	if min_pos_x == null:
		return
	
	match (movement_pattern):
		MovementPattern.SQUARE_UP, MovementPattern.SQUARE_DOWN:
			if position.x >= max_pos_x:
				_direction = Vector2.LEFT
			if position.x <= min_pos_x:
				_direction = Vector2.RIGHT
	
	position.x = clamp(position.x, min_pos_x, max_pos_x)


func set_movement_pattern(value) -> void:
	movement_pattern = value
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
			print_debug("Unknown movement pattern: %s. Will default to VERTICAL_DOWN." % str(value))
			movement_pattern = MovementPattern.VERTICAL_DOWN
			_direction = Vector2.DOWN
	
	_correct_initial_pos_x()


func _on_VisibilityNotifier2D_viewport_exited(_viewport : Viewport) -> void:
	queue_free()


func _on_Dron_area_entered(area: Area2D) -> void:
	kill(area)
