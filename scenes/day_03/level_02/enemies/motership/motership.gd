extends Node2D


signal died

@export var debug_show_hp: bool = false:
	set(value):
		debug_show_hp = value
		_on_debug_show_hp_set()
@export var _hp: int = 1:
	set(value):
		var _old_hp = _hp
		_hp = maxi(value, 0)
		if _old_hp != _hp:
			_on_hp_changed()
@export var _activate_block_spawner_at_hp: int = 1
@export var _speed_up_block_spawner_at_hp: int = 1
@export var _activate_heat_seeker_at_hp: int = 1
@export var Explosion: PackedScene

var _is_dead: bool = false
var _player: Day03Player

@onready var _block_spawner_weapon := $BlockSpawnerWeapon
@onready var _heat_seeker_weapon := $HeatSeekerWeapon
@onready var _laser_balls_weapon := $LaserBallsWeapon
@onready var _alien_hologram := $AlienHologram
@onready var _flash := %Flash
@onready var _hp_label := $Debug/HpLabel as Label
@onready var _is_ready: bool = true


func _ready() -> void:
	initialize($Player)
	_update_hp_label() 
	_on_debug_show_hp_set()
	_on_hp_changed()


func initialize(player: Day03Player) -> void:
	_player = player
	_heat_seeker_weapon.target = _player
	_block_spawner_weapon.target = _player
	_laser_balls_weapon.target = _player


func is_dead() -> bool:
	return _is_dead


func is_ready() -> bool:
	return _is_ready


func _update_hp_label() -> void:
	if is_ready():
		_hp_label.text = "HP: %s" % _hp


func _on_debug_show_hp_set() -> void:
	if is_ready():
		_hp_label.visible = debug_show_hp


func _activate_weapons() -> void:
	if not is_ready():
		return
	_heat_seeker_weapon.is_active = _hp <= _activate_heat_seeker_at_hp
	_block_spawner_weapon.is_active = _hp <= _activate_block_spawner_at_hp
	_block_spawner_weapon.is_max_speed_enabled = _hp <= _speed_up_block_spawner_at_hp


func _on_hp_changed() -> void:
	_update_hp_label()
	_activate_weapons()


func _remove_hazards() -> void:
	var bullets = Utils.children_in_group(self, "enemy_bullets")
	for bullet in bullets:
		_spawn_explosion(bullet.position)
	Utils.queue_free_group(self, "bullets")
	get_tree().call_group("enemies", "explode")


func _disable_wapons() -> void:
	_heat_seeker_weapon.is_active = false
	_block_spawner_weapon.is_active = false
	_laser_balls_weapon.is_active = false


func _animate_flash() -> void:
	var tween_flash = create_tween()
	tween_flash.set_loops(4)
	tween_flash.tween_callback(_flash.set_visible.bind(true))
	tween_flash.tween_interval(Utils.FRAME_TIME)
	tween_flash.tween_callback(_flash.set_visible.bind(false))
	tween_flash.tween_interval(Utils.FRAME_TIME * 10)


func _animate_explosions() -> void:
	var viewport_rect_size = get_viewport_rect().size
	var tween_explosion = create_tween()
	tween_explosion.set_loops()
	tween_explosion.tween_callback(func():
		for i in 10:
			var random_x = randi() % int(viewport_rect_size.x)
			var random_y = randi() % int(viewport_rect_size.y)
			var random_pos = Vector2i(random_x, random_y)
			_spawn_explosion(random_pos)
	)
	tween_explosion.tween_interval(Utils.FRAME_TIME)


func _explode() -> void:
	Utils.vibrate_joy(0, 0.25, 0.25, 2.9)
	_animate_flash()
	_animate_explosions()


func _die() -> void:
	if is_dead():
		return
	
	_is_dead = true
	_disable_wapons()
	_remove_hazards()
	_explode()
	died.emit()


func _hurt( ) -> void:
	if is_dead():
		return
	
	_hp -= 1
	if _hp <= 0:
		_die()


func _spawn_explosion(pos: Vector2) -> void:
	var explosion = Explosion.instantiate()
	add_child(explosion)
	explosion.position = pos


func _on_hurt_box_hurt(who) -> void:
	_hurt()
	who.queue_free()
