class_name Day03Player
extends Area2D

signal mega_gun_shot
signal died(remaining_lives)

const SPEED: float = 62.5
const STAMINA_POINTS_DEPLETED_PER_TICK: int = 4

@export var _player_data: Day03PlayerData
@export var is_autofire_enabled: bool = false
@export var debug_invincible: bool = false
@export var Fall: PackedScene
@export var Explosion: PackedScene

var is_input_enabled: bool = true

var _is_dead: bool = false
var _min_pos: Vector2
var _max_pos: Vector2

@onready var _world = get_parent()
@onready var _gun := $Gun as Gun
@onready var _mega_gun := $MegaGun
@onready var _animation_player := $AnimationPlayer as AnimationPlayer
@onready var _animation_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _collision_shape: = $CollisionShape2D as CollisionShape2D
@onready var _stamina_timer := $StaminaDepletionTimer as Timer


func _ready() -> void:
	_calculate_max_movement()
	reset_stamina()
	start_timed_invincibility()


func _process(delta: float) -> void:
	_process_movement(delta)
	_process_fire()


func is_dead() -> bool:
	return _is_dead


func start_timed_invincibility() -> void:
	_animation_player.play("invincible")


func explode() -> void:
	var explosion = Explosion.instantiate()
	explosion.centered = _animation_sprite.centered
	explosion.global_position = global_position
	_world.add_child(explosion)
	Utils.vibrate_joy()
	_die()


func plummet() -> void:
	var fall = Fall.instantiate()
	fall.global_position = global_position
	_world.add_child(fall)
	Utils.vibrate_joy()
	_die()


func add_points_to_score(points: int) -> void:
	_player_data.score += points


func reset_power_up() -> void:
	_player_data.reset_power_up()


func reset_stamina() -> void:
	_player_data.reset_stamina()


func add_stamina(stamina: int) -> void:
	_player_data.stamina += stamina


func is_stamina_depleted() -> bool:
	return _player_data.stamina <= 0


func power_up_by(points: int) -> void:
	_player_data.power_up_count += points


func stop_stamina_lose(pause_lose: bool) -> void:
	if _is_dead:
		return
	if pause_lose:
		_stamina_timer.stop()
	else:
		_stamina_timer.start()


func revive(skip_timed_invincibility: bool = false) -> void:
	if not _is_dead:
		return
	_is_dead = false
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	_player_data.reset_stamina()
	_stamina_timer.start()
	if not skip_timed_invincibility:
		start_timed_invincibility()


func _calculate_max_movement() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	var texture := _animation_sprite.sprite_frames.get_frame_texture("default", 0) as Texture2D
	var player_extents: Vector2 = _collision_shape.shape.extents
	_min_pos.x = -player_extents.x
	_min_pos.y = 2
	_max_pos.x = screen_size.x - texture.get_width() + player_extents.x
	_max_pos.y = screen_size.y - texture.get_height()


func _die() -> void:
	if _is_dead: return
	_is_dead = true
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	visible = false
	_stamina_timer.stop()
	_player_data.lives -= 1
	died.emit(_player_data.lives)


func _process_movement(delta: float) -> void:
	if not is_input_enabled:
		return
	
	var velocity = SPEED * Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	_move(velocity, delta)


func _is_powered_up() -> bool:
	return _player_data.is_power_up_maximized()


func _can_autofire() -> bool:
	return is_autofire_enabled and not _is_powered_up()
	

func _is_trying_to_fire() -> bool:
	return Input.is_action_pressed("fire") or _can_autofire()


func _process_fire() -> void:
	if not is_input_enabled: return
	
	if not _is_trying_to_fire():
		if _is_powered_up():
			_mega_gun.prepare()
		return
	
	if not _is_powered_up():
		_gun.shoot(Vector2.UP)
		return
	
	if _mega_gun.shoot():
		reset_power_up()
		mega_gun_shot.emit()


func _move(velocity: Vector2, delta: float) -> void:
	position += velocity * delta
	position.x = clamp(position.x, _min_pos.x, _max_pos.x)
	position.y = clamp(position.y, _min_pos.y, _max_pos.y)


func _on_HurtBox_hurt(who: Area2D) -> void:
	if _is_dead:
		return
	if who.is_in_group("bullets"): 
		who.queue_free() # WORKAROUND See _on_area_entered FIXME in Bullet.gd
	elif who.has_method("impacted"):
		who.impacted()
	elif who.has_method("explode"):
		who.explode()
	if not debug_invincible:
		explode()


func _on_Player_area_entered(area: Area2D) -> void:
	if _is_dead:
		return
	if area.has_method("pick_up"):
		area.pick_up(self)


func _on_StaminaDepletionTimer_timeout() -> void:
	if _is_dead or debug_invincible:
		return
	add_stamina(-STAMINA_POINTS_DEPLETED_PER_TICK)
	if is_stamina_depleted():
		plummet()
