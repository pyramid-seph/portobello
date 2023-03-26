class_name Drone
extends Area2D

const SCORE_POINTS_GUN: int = 10
const SCORE_POINTS_MEGA_GUN: int = 5


@export var Explosion: PackedScene
@export var speed: float = 87.5:
	set(value): 
		speed = value
		_on_set_speed()
@export var movement_pattern: SimpleMover.Pattern:
	set(value):
		movement_pattern = value
		_on_set_movement_pattern()

var world: Node2D:
	set(value):
		world = value
		_on_set_world()

@onready var _gun := $Gun as Gun
@onready var _simple_mover := $SimpleMover as SimpleMover
@onready var _sprite := $Sprite2D as Sprite2D
@onready var _is_ready: bool = true


func _ready() -> void:
	_on_set_world()
	_on_set_speed()
	_setup_min_max_x_movement()
	_on_set_movement_pattern()


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
	explosion.centered = _sprite.centered
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


func _on_set_speed() -> void:
	if _is_ready:
		_simple_mover.speed = speed


func _on_set_movement_pattern() -> void:
	if _is_ready:
		_simple_mover.pattern = movement_pattern


func _on_set_world() -> void:
	if _is_ready:
		_gun.world = _world_or_default()


func _setup_min_max_x_movement() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_width: float = viewport_size.x
	var sprite_width: float = _sprite.texture.get_width()
	_simple_mover.min_pos_x = 0.0
	_simple_mover.max_pos_x = viewport_width - sprite_width


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_drone_area_entered(area: Area2D) -> void:
	var killer = area.shooter if area.is_in_group("bullets") else area
	kill(killer)
