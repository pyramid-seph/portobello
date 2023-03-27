extends Area2D

signal died

enum DisposeMode {
	DESTROY,
	DISABLE_PROCESS,
}

@export var score_points_gun: int = 0
@export var score_points_mega_gun: int = 0
@export var hp: int = 1
@export var is_immune_to_bullets: bool = false
@export var is_immune_to_impacts: bool = false
@export var dispose_mode: DisposeMode = DisposeMode.DESTROY
@export var Explosion: PackedScene = preload("res://scenes/day_03/_shared/objects/Explosion.tscn")

var world: Node2D:
	set(value): 
		world = value
		_internal_on_set_world()

var _is_dead: bool = false

@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _is_ready: bool = true


func _ready() -> void:
	_internal_on_set_world()


func is_ready() -> bool:
	return _is_ready


func is_dead() -> bool:
	return _is_dead


func kill(killer: Node, killed_by_mega_gun: bool = false) -> void:
	if killer and killer.has_method("add_points_to_score"):
		killer.add_points_to_score(
			score_points_mega_gun if killed_by_mega_gun else score_points_gun
		)
	explode()


func impacted() -> void:
	if is_immune_to_impacts:
		return
	explode()


func explode() -> void:
	if is_dead():
		return
	_spawn_explosion()
	_die()


func hurt(killer: Node, damage: int = 1) -> void:
	if is_dead():
		return
	hp -= damage
	if hp > 0:
		_spawn_explosion()
	else:
		kill(killer)


func get_animated_sprite() -> AnimatedSprite2D:
	return _animated_sprite


func _on_set_world(_new_world) -> void:
	pass


func _dispose() -> void:
	if dispose_mode == DisposeMode.DISABLE_PROCESS:
		visible = false
		call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
	else:
		queue_free()


func _spawn_explosion() -> void:
	var explosion = Explosion.instantiate()
	explosion.centered = get_animated_sprite().centered
	explosion.global_position = global_position
	_world_or_default().add_child(explosion)


func _internal_on_set_world() -> void:
	if is_ready():
		_on_set_world(_world_or_default())


func _die() -> void:
	_is_dead = true
	_dispose()
	died.emit()


func _world_or_default() -> Node2D:
	if world:
		return world
	elif owner and owner.get_parent():
		return owner.get_parent()
	elif owner:
		return owner
	else:
		return get_node("/root")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_dispose()


func _on_area_entered(area: Area2D) -> void:
	if is_dead(): 
		return
	if is_immune_to_bullets:
		_spawn_explosion()
	elif area.is_in_group("bullets"): 
		hurt(area.shooter)
