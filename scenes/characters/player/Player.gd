extends Area2D

const SPEED := 40.0
const INVINCIBILITY_DURATION := 1.0

export(Texture) var invincibility_start_texture = null
export(Texture) var invincibility_about_to_end_texture = null

onready var gun := $Gun
onready var mega_gun := $MegaGun
onready var hurt_box := $HurtBox
onready var shield = $Shield
onready var animated_sprite := $AnimatedSprite
onready var collision_shape := $CollisionShape2D
onready var screen_size := get_viewport_rect().size
onready var player_extents = collision_shape.shape.extents

var _min_pos_x := 0.0
var _min_pos_y := 0.0
var _max_pos_x := 0.0
var _max_pos_y := 0.0


func _ready():
	_min_pos_x = player_extents.x
	_min_pos_y = player_extents.y
	_max_pos_x = screen_size.x - player_extents.x
	_max_pos_y = screen_size.y - player_extents.y


func _input(event) -> void:
	if event.is_action_pressed("fire"):
		_fire()


func _process(delta: float) -> void:
	var velocity = SPEED * Input.get_vector(
		"move_left",
		"move_right",
		"move_up", 
		"move_down"
	)
	_move(velocity, delta)


func revive(pos: Vector2) -> void:
	position = pos
	animated_sprite.play("default")
	hurt_box.disabled = false
	collision_shape.set_deferred("disabled", false)
	hurt_box.start_timed_invincibility(INVINCIBILITY_DURATION)
	show()


func die() -> void:
	PlayerData.lives -= 1
	hurt_box.disabled = true
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("explode")


func is_powered_up() -> bool:
	return PlayerData.power_up_count >= 5


func _fire() -> void:
	if is_powered_up():
		mega_gun.shoot()
	else:
		gun.shoot(Vector2.UP)


func _move(velocity: Vector2, delta: float):
	position += velocity * delta
	position.x = clamp(position.x, _min_pos_x, _max_pos_x)
	position.y = clamp(position.y, _min_pos_y, _max_pos_y)


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "explode":
		queue_free()


func _on_HurtBox_hurt(who: Area2D) -> void:
	if who.has_method("explode"):
		who.explode()

	die()


func _on_Player_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickups"):
		area.pick_up()


func _on_HurtBox_invincibility_started() -> void:
	shield.visible = true


func _on_HurtBox_invincibility_ended() -> void:
	shield.visible = false
