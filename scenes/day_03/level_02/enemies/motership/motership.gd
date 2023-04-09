extends Node2D


signal died

@export var debug_show_hp: bool = false:
	set(value):
		debug_show_hp = value
		_on_debug_show_hp_set()
@export var _hp: int = 1:
	set(value):
		_hp = value
		_update_hp_label()
@export var _phase_2_at_hp: int = 1
@export var _phase_3_at_hp: int = 1
@export var Explosion: PackedScene

var _is_dead: bool = false
var _player: Day03Player

@onready var _block_spawner_weapon := $BlockSpawnerWeapon
@onready var _heat_seeker_weapon := $HeatSeekerWeapon
@onready var _laser_balls_weapon := $LaserBallsWeapon
@onready var _alien_hologram := $AlienHologram
@onready var _flash := %Flash
@onready var _hp_label := $FlashContainer/HpLabel as Label
@onready var _is_ready: bool = true


func _ready() -> void:
	initialize($Player)
	_on_debug_show_hp_set()
	$Timer.timeout.connect(func(): _hp -= 1)


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
		_update_hp_label() 


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
	
	_disable_wapons()
	_remove_hazards()
	_explode()
	died.emit()


func _spawn_explosion(pos: Vector2) -> void:
	var explosion = Explosion.instantiate()
	add_child(explosion)
	explosion.position = pos


func _on_weak_point_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_laser_balls_cannon_charged() -> void:
	pass # Replace with function body.
