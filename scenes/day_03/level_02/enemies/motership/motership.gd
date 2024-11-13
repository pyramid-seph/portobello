extends Node2D


signal died

const SFX_MOTERSHIP_AMBIANCE = preload("res://audio/ambience/sfx_motership_ambience.wav")

@export var _initial_hp: int = 1
@export var is_attacking: bool:
	set(value):
		var old_value = is_attacking
		is_attacking = value
		if is_attacking != old_value:
			_on_is_attacking_changed()
@export var _activate_block_spawner_at_hp: int = 1
@export var _speed_up_block_spawner_at_hp: int = 1
@export var _activate_heat_seeker_at_hp: int = 1
@export var player: Day03Player:
	set(value):
		player = value
		_on_player_set()
@export var Explosion: PackedScene

var _tween_explosion: Tween
var _is_dead: bool
var _hp: int = 1:
	set(value):
		var _old_hp = _hp
		_hp = maxi(value, 0)
		if _old_hp != _hp:
			_on_hp_changed()

@onready var _block_spawner_weapon := $BlockSpawnerWeapon
@onready var _heat_seeker_weapon := $HeatSeekerWeapon
@onready var _laser_balls_weapon := $LaserBallsWeapon
@onready var _alien_hologram := $Inside/AlienHologram
@onready var _flash := %Flash
@onready var _inside := $Inside as Node2D
@onready var _explosions_container := $ExplosionsContainer as Node2D
@onready var _start_position := $Inside/StartPosition
@onready var _abduction_ray := $AbductionRay
@onready var _dialogue_box := $Control/DialogueBox as DialogueBox
@onready var _life_bar := %LifeBar as TextureProgressBar
@onready var _is_ready := true


func _ready() -> void:
	SoundManager.play_ambient_sound(SFX_MOTERSHIP_AMBIANCE, 0.7)
	_hp = _initial_hp
	_on_player_set()
	_on_is_attacking_changed()


func _exit_tree() -> void:
	SoundManager.stop_ambient_sound(SFX_MOTERSHIP_AMBIANCE)


func is_dead() -> bool:
	return _is_dead


func is_ready() -> bool:
	return _is_ready


func start_abduction_ray() -> void:
	_abduction_ray.start()


func stop_abduction_ray() -> void:
	_abduction_ray.stop()


func introduce_alien() -> void:
	_alien_hologram.visible = true
	_dialogue_box.start()
	await _dialogue_box.finished
	_alien_hologram.visible = false
	SoundManager.stop_ambient_sound(SFX_MOTERSHIP_AMBIANCE, 1.0)


func stop_exploding() -> void:
	if _tween_explosion:
		_tween_explosion.kill()
	_tween_explosion = null


func _move_player_inside() -> void:
	if player == null:
		return
	Utils.safe_reparent(player, _inside)
	player.global_position = _start_position.global_position
	player.move_offset_left = 52
	player.move_offset_bottom = -32
	player.move_offset_right = -52
	player.move_offset_top = 143
	player.revived.connect(_on_player_revived)


func _update_hp_bar() -> void:
	var value: float = (_hp * _life_bar.max_value) / _initial_hp
	_life_bar.value = Utils.round_up(value, _life_bar.step)


func _on_player_set() -> void:
	if not _is_ready:
		return
	_move_player_inside()
	_heat_seeker_weapon.target = player
	_block_spawner_weapon.target = player


func _on_is_attacking_changed() -> void:
	if not _is_ready:
		return
	if is_attacking:
		_enable_weapons()
	else:
		_disable_weapons()


func _disable_weapons() -> void:
	_heat_seeker_weapon.is_active = false
	_block_spawner_weapon.is_active = false
	_laser_balls_weapon.is_active = false


func _enable_weapons() -> void:
	_laser_balls_weapon.is_active = true
	_heat_seeker_weapon.is_active = _hp <= _activate_heat_seeker_at_hp
	_block_spawner_weapon.is_active = _hp <= _activate_block_spawner_at_hp
	_block_spawner_weapon.is_max_speed_enabled = _hp <= _speed_up_block_spawner_at_hp


func _on_hp_changed() -> void:
	if not is_ready():
		return
	_update_hp_bar()
	_enable_weapons()


func _remove_hazards() -> void:
	var bullets = Utils.children_in_group(_inside, "enemy_bullets")
	for bullet: Node2D in bullets:
		_spawn_explosion(bullet.global_position)
	Utils.queue_free_group(_inside, "bullets")
	get_tree().call_group("enemies", "explode")


func _animate_flash() -> void:
	var tween_flash = create_tween()
	tween_flash.set_loops(4)
	tween_flash.tween_callback(_flash.set_visible.bind(true))
	tween_flash.tween_interval(Utils.FRAME_TIME)
	tween_flash.tween_callback(_flash.set_visible.bind(false))
	tween_flash.tween_interval(Utils.FRAME_TIME * 10)


func _explode() -> void:
	var viewport_rect_size = get_viewport_rect().size
	if _tween_explosion:
		_tween_explosion.kill()
	_tween_explosion = create_tween()
	_tween_explosion.set_loops()
	_tween_explosion.tween_callback(func():
		for i: int in 10:
			var random_x = randi() % int(viewport_rect_size.x)
			var random_y = randi() % int(viewport_rect_size.y)
			var random_pos = Vector2i(random_x, random_y)
			_spawn_explosion(random_pos)
	)
	_tween_explosion.tween_interval(Utils.FRAME_TIME)


func _die() -> void:
	if is_dead():
		return
	_is_dead = true
	is_attacking = false
	Utils.vibrate_joy(0, 0.25, 0.25, 2.9)
	_animate_flash()
	_explode()
	_remove_hazards()
	died.emit()


func _take_damage() -> void:
	if is_dead():
		return
	
	_hp -= 1
	if _hp <= 0:
		_die()


func _spawn_explosion(pos: Vector2,
		center: bool = false, 
		world: Node2D = _explosions_container) -> void:
	var explosion = Explosion.instantiate()
	world.add_child(explosion)
	explosion.z_index = 0
	explosion.centered = center
	explosion.global_position = pos


func _on_hurtbox_hurt(_hitbox: Hitbox) -> void:
	_take_damage()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.owner and area.owner.is_in_group("player_bullets"):
		_spawn_explosion(area.owner.global_position, true, _inside)


func _on_player_revived() -> void:
	player.global_position = _start_position.global_position
