class_name BaseDay03Enemy
extends Node2D

signal died

enum DisposeMode {
	DESTROY,
	DISABLE_PROCESS,
}

const SFX_BULLET_SHIELD_IMPACTED = preload("res://audio/sfx/sfx_day_03_bullet_shield_impacted.wav")
 
@export var score_points_gun: int
@export var score_points_mega_gun: int
@export var hp: int = 1
@export var is_immune_to_bullets: bool:
	set(value):
		var old_value = is_immune_to_bullets
		is_immune_to_bullets = value
		if is_immune_to_bullets != old_value:
			_on_bullet_immunity_changed()
@export var is_immune_to_impacts: bool
@export var dispose_mode: DisposeMode = DisposeMode.DESTROY
@export var Explosion: PackedScene = preload("res://scenes/day_03/_shared/objects/explosion.tscn")

var world: Node2D:
	set(value):
		world = value
		_internal_on_set_world()

var _is_dead: bool = false

@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D


func _ready() -> void:
	_internal_on_set_world()


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


func get_width() -> float:
	return _animated_sprite.sprite_frames.get_frame_texture("default", 0).get_width()


func get_height() -> float:
	return _animated_sprite.sprite_frames.get_frame_texture("default", 0).get_height()

# override
func _on_bullet_immunity_changed() -> void:
	pass


func _on_set_world(_new_world) -> void:
	pass


func _dispose() -> void:
	if dispose_mode == DisposeMode.DISABLE_PROCESS:
		visible = false
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	else:
		queue_free()


func _spawn_explosion() -> void:
	var explosion = Explosion.instantiate()
	explosion.centered = _animated_sprite.centered
	explosion.global_position = global_position
	_world_or_default().add_child(explosion)


func _internal_on_set_world() -> void:
	if is_node_ready():
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
	elif get_parent() is Node2D:
		return get_parent()
	else:
		return get_node("/root")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_dispose()


func _on_hitbox_hit(_hitbox:Hitbox, hurtbox: Hurtbox) -> void:
	if is_dead(): 
		return
	if hurtbox.owner.is_in_group("players"):
		impacted()


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	if is_immune_to_bullets:
		if not SoundUtils.is_sfx_started_playing(SFX_BULLET_SHIELD_IMPACTED):
			SoundManager.play_sound(SFX_BULLET_SHIELD_IMPACTED)
	else:
		hurt(hitbox.owner.shooter)
