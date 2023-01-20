extends Area2D
class_name HiveDrone

signal dead(killer)


@export var hp: int = 50
@export var is_immune_to_bullets: bool = false
@export var explosion: PackedScene

var is_dead: bool = false

@onready var gun := $Gun
@onready var world := get_parent()
@onready var collision_shape = $CollisionShape2D


func shoot() -> bool:
	return gun.shoot(Vector2.DOWN)


func hurt(killer: Node) -> void:
	if is_dead:
		return
	hp -= 1
	if hp > 0:
		_spawn_explosion()
	else:
		kill(killer)


func kill(killer: Node) -> void:
	if is_dead:
		return
	_spawn_explosion()
	_die(killer)


func _die(killer: Node) -> void:
	is_dead = true
	set_process(false)
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	visible = false
	dead.emit(killer)


func _spawn_explosion() -> void:
	var new_explosion = explosion.instantiate()
	new_explosion.centered = false
	new_explosion.position = position
	world.add_child(new_explosion)


func _on_drone_area_entered(area: Area2D) -> void:
	if is_dead:
		return
	if is_immune_to_bullets:
		_spawn_explosion()
	elif area.is_in_group("bullets"):
		hurt(area.shooter)
