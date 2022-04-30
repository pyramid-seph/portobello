extends Area2D

export var speed = 40
export var is_auto_fire_enabled = false

onready var gun = $Gun
onready var mega_gun = $MegaGun
onready var screen_size = get_viewport_rect().size
onready var player_size = $AnimatedSprite.frames.get_frame("default", 0)
onready var min_pos_x = player_size.get_width()
onready var min_pos_y = player_size.get_height()


func _input(event) -> void:
	if not is_auto_fire_enabled and event.is_action_pressed("fire"):
		_fire()


func _process(delta: float) -> void:
	var velocity = speed * Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_move(velocity, delta)

	if is_auto_fire_enabled:
		_fire()


func revive(pos: Vector2) -> void:
	position = pos
	$InvincibilityTimer.start()
	$AnimatedSprite.play("default")
	$CollisionShape2D.disabled = true
	show()


func die() -> void:
	PlayerData.lives -= 1
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite.play("explode")


func is_powered_up() -> bool:
	return PlayerData.power_up_count >= 5


func _fire() -> void:
	if is_powered_up():
		mega_gun.shoot()
	else:
		gun.shoot(Vector2.UP)


func _move(velocity: Vector2, delta: float):
	position += velocity * delta
	var max_pos_x = screen_size.x - min_pos_x
	var max_pos_y = screen_size.y - min_pos_y
	position.x = clamp(position.x, min_pos_x, max_pos_x)
	position.y = clamp(position.y, min_pos_y, max_pos_y)


func _on_InvincibilityTimer_timeout() -> void:
	$CollisionShape2D.disabled = false


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "explode":
		queue_free()


func _on_area_entered(area) -> void:
	if not area.is_in_group("pickups"):
		die()
