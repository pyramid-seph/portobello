extends Area2D
class_name HiveDrone

signal dead(killer)


@export var hp: int = 50
@export var is_immune_to_bullets: bool = false
@export var explosion: PackedScene

@onready var gun := $Gun
@onready var world: Node2D = get_parent()
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func shoot() -> bool:
	return gun.shoot(Vector2.DOWN)


func hurt(killer: Node) -> void:
	hp -= 1
	if hp > 0:
		_spawn_explosion()
	else:
		kill(killer)


func kill(killer: Node) -> void:
	_spawn_explosion()
	dead.emit(killer)
	queue_free()


func _spawn_explosion() -> void:
	var new_explosion = explosion.instantiate()
	new_explosion.centered = animated_sprite.centered
	new_explosion.global_position = global_position
	world.add_child(new_explosion)


func _on_drone_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion() or is_immune_to_bullets:
		return
	if area.is_in_group("bullets"):
		hurt(area.shooter)
