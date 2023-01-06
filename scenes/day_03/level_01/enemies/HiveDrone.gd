extends Area2D
class_name HiveDrone

signal dead

const SCORE_POINTS: int = 10

@export var hp: int = 50
@export var explosion: PackedScene

@onready var gun := $Gun
@onready var world: Node2D = get_parent()
@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var viewport_width: float = viewport_size.x
@onready var viewport_height: float = viewport_size.y
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_width: float = animated_sprite.frames.get_frame("default", 0).get_width()
@onready var min_pos_x: float = 0.0
@onready var max_pos_x: float = viewport_width - sprite_width


func shoot() -> bool:
	return gun.shoot(Vector2.DOWN)


func hurt(killer: Node) -> void:
	hp -= 1
	if hp > 0:
		_spawn_explosion()
	else:
		kill(killer)


func kill(killer: Node) -> void:
	if killer and killer.has_method("add_points_to_score"):
		killer.add_points_to_score(SCORE_POINTS)
	_explode()


func _explode() -> void:
	_spawn_explosion()
	dead.emit()
	queue_free()


func _spawn_explosion() -> void:
	var new_explosion = explosion.instantiate()
	new_explosion.centered = animated_sprite.centered
	new_explosion.global_position = global_position
	world.add_child(new_explosion)


func _on_drone_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets"):
		hurt(area.shooter)
	else:
		kill(area)
