extends Area2D

signal mega_gun_shot
signal died(remaining_lives)

const SPEED: float = 40.0
const STAMINA_POINTS_DEPLETED_PER_TICK: int = 4

export(Resource) var player_data: Resource
export(PackedScene) var fall: PackedScene
export(PackedScene) var explosion: PackedScene

onready var world := get_parent()
onready var gun := $Gun
onready var mega_gun := $MegaGun
onready var hurt_box := $HurtBox
onready var animation_player := $AnimationPlayer
onready var animated_sprite := $AnimatedSprite
onready var player_extents = $CollisionShape2D.shape.extents
onready var screen_size := get_viewport_rect().size
onready var min_pos_x: float = player_extents.x
onready var min_pos_y: float = player_extents.y
onready var max_pos_x: float = screen_size.x - player_extents.x
onready var max_pos_y: float = screen_size.y - player_extents.y


func _ready() -> void:
	player_data.reset_stamina()
	start_timed_invincibility()


func _process(delta: float) -> void:
	_process_movement(delta)
	_process_fire()


func start_timed_invincibility() -> void:
	animation_player.play("invincible")


func explode() -> void:
	var new_explosion = explosion.instance()
	new_explosion.global_position = global_position
	world.add_child(new_explosion)
	Input.start_joy_vibration(0, 0.25, 0.25, 0.25)
	_die()


func plummet() -> void:
	var new_fall = fall.instance()
	new_fall.global_position = global_position
	world.add_child(new_fall)
	Input.start_joy_vibration(0, 0.25, 0.25, 0.25)
	_die()


func add_points_to_score(points: int) -> void:
	player_data.score += points


func add_stamina(stamina: int) -> void:
	player_data.stamina += stamina


func power_up_by(points: int) -> void:
	player_data.power_up_count += points


func _die() -> void:
	player_data.lives -= 1
	emit_signal("died", player_data.lives)
	queue_free()


func _process_movement(delta: float) -> void:
	var velocity = SPEED * Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	_move(velocity, delta)


func _is_powered_up() -> bool:
	return player_data.power_up_count == player_data.MAX_POWER_UP


func _process_fire() -> void:
	if not Input.is_action_pressed("fire"):
		if _is_powered_up():
			mega_gun.prepare()
		return

	if not _is_powered_up():
		gun.shoot(Vector2.UP)
		return

	if mega_gun.shoot():
		player_data.power_up_count = 0
		emit_signal("mega_gun_shot")


func _move(velocity: Vector2, delta: float) -> void:
	position += velocity * delta
	position.x = clamp(position.x, min_pos_x, max_pos_x)
	position.y = clamp(position.y, min_pos_y, max_pos_y)


func _on_HurtBox_hurt(who: Area2D) -> void:
	if who.has_method("explode"):
		who.explode()
	explode()


func _on_Player_area_entered(area: Area2D) -> void:
	if area.has_method("pick_up"):
		area.pick_up(self)


func _on_StaminaDepletionTimer_timeout() -> void:
	player_data.stamina -= STAMINA_POINTS_DEPLETED_PER_TICK
	if player_data.stamina == 0:
		plummet()
