class_name HiveDrone
extends Area2D


signal dead(killer)

@export var hp: int = 50
@export var is_immune_to_bullets: bool = false
@export var Explosion: PackedScene

var world: Node2D:
	set(value):
		world = value
		if not _is_ready: return
		gun.world = value

var _is_dead: bool = false

@onready var gun := $Gun
@onready var collision_shape = $CollisionShape2D
@onready var _is_ready = true


func _ready() -> void:
	gun.world = _world_or_default()


func shoot() -> bool:
	return gun.shoot(Vector2.DOWN)


func hurt(killer: Node) -> void:
	if _is_dead:
		return
	hp -= 1
	if hp > 0:
		_spawn_explosion()
	else:
		kill(killer)


func explode() -> void:
	if _is_dead: return
	_spawn_explosion()
	_die()


func kill(_killer: Node, _killed_by_mega_gun: bool = false) -> void:
	if _is_dead: return
	explode()


func _world_or_default() -> Node2D:
	if world:
		return world
	elif owner and owner.get_parent():
		return owner.get_parent()
	else:
		return get_node("/root")


func _die() -> void:
	_is_dead = true
	visible = false
	call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
	dead.emit()


func _spawn_explosion() -> void:
	var new_explosion = Explosion.instantiate()
	new_explosion.centered = false
	new_explosion.global_position = global_position
	_world_or_default().add_child(new_explosion)


func _on_drone_area_entered(area: Area2D) -> void:
	if _is_dead: 
		return
	if is_immune_to_bullets:
		_spawn_explosion()
	elif area.is_in_group("bullets"): 
		hurt(area.shooter)
