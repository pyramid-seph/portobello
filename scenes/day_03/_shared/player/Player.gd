extends Area2D

signal mega_gun_shot
signal died(remaining_lives)

const SPEED: float = 62.5
const STAMINA_POINTS_DEPLETED_PER_TICK: int = 4

@export var player_data: Day03PlayerData
@export var fall: PackedScene
@export var explosion: PackedScene
@export var debug_invincible: bool = false

var _is_dead: bool = false
var is_input_enabled: bool = true:
	set(value):
		is_input_enabled = value
		if not is_input_enabled: mega_gun.revert_preparations()
	get:
		return is_input_enabled

@onready var world = get_parent()
@onready var gun := $Gun
@onready var mega_gun := $MegaGun
@onready var hurt_box := $HurtBox as HurtBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: = $CollisionShape2D as CollisionShape2D
@onready var player_extents: Vector2 = collision_shape.shape.extents
@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var min_pos_x: float = player_extents.x
@onready var min_pos_y: float = player_extents.y
@onready var max_pos_x: float = screen_size.x - player_extents.x
@onready var max_pos_y: float = screen_size.y - player_extents.y
@onready var stamina_timer := $StaminaDepletionTimer as Timer


func _ready() -> void:
	player_data.reset_stamina()
	start_timed_invincibility()


func _process(delta: float) -> void:
	_process_movement(delta)
	_process_fire()


func is_dead() -> bool:
	return _is_dead

func start_timed_invincibility() -> void:
	animation_player.play("invincible")


func explode() -> void:
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = global_position
	world.add_child(new_explosion)
	Utils.vibrate_joy()
	_die()


func plummet() -> void:
	var new_fall = fall.instantiate()
	new_fall.global_position = global_position
	world.add_child(new_fall)
	Utils.vibrate_joy()
	_die()


func add_points_to_score(points: int) -> void:
	player_data.score += points


func reset_power_up() -> void:
	player_data.reset_power_up()


func reset_stamina() -> void:
	player_data.reset_stamina()


func add_stamina(stamina: int) -> void:
	player_data.stamina += stamina


func power_up_by(points: int) -> void:
	player_data.power_up_count += points


func stop_stamina_lose(pause_lose: bool) -> void:
	if _is_dead: return
	if pause_lose:
		stamina_timer.stop()
	else:
		stamina_timer.start()


func revive(skip_timed_invincibility: bool = false) -> void:
	if not _is_dead:
		return

	_is_dead = false
	set_process_input(true)
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(true)
	visible = true
	player_data.reset_stamina()
	collision_shape.disabled = false
	hurt_box.invincible = false
	stamina_timer.start()
	if not skip_timed_invincibility:
		start_timed_invincibility()


func _die() -> void:
	if _is_dead: return
	_is_dead = true
	set_process_input(false)
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	collision_shape.set_deferred("disabled", true)
	hurt_box.invincible = true
	visible = false
	player_data.lives -= 1
	died.emit(player_data.lives)
	stamina_timer.stop()


func _process_movement(delta: float) -> void:
	if not is_input_enabled: return
	
	var velocity = SPEED * Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	_move(velocity, delta)


func _is_powered_up() -> bool:
	return player_data.is_power_up_maximized()


func _process_fire() -> void:
	if not is_input_enabled: return
	
	if not Input.is_action_pressed("fire"):
		if _is_powered_up():
			mega_gun.prepare()
		return
	
	if not _is_powered_up():
		gun.shoot(Vector2.UP)
		return
	
	if mega_gun.shoot():
		player_data.power_up_count = 0
		mega_gun_shot.emit()


func _move(velocity: Vector2, delta: float) -> void:
	position += velocity * delta
	position.x = clamp(position.x, min_pos_x, max_pos_x)
	position.y = clamp(position.y, min_pos_y, max_pos_y)


func _on_HurtBox_hurt(who: Area2D) -> void:
	if _is_dead or debug_invincible: return
	if who.is_in_group("bullets"): 
		who.queue_free() # WORKAROUND See _on_area_entered FIXME in Bullet.gd
	if who.has_method("explode"):
		who.explode()
	explode()


func _on_Player_area_entered(area: Area2D) -> void:
	if _is_dead: return
	if area.has_method("pick_up"):
		area.pick_up(self)


func _on_StaminaDepletionTimer_timeout() -> void:
	if _is_dead or debug_invincible: return
	player_data.stamina -= STAMINA_POINTS_DEPLETED_PER_TICK
	if player_data.stamina == 0:
		plummet()
