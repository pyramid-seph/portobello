extends Area2D

signal mega_gun_shot
signal died


const SPEED := 40.0

onready var gun := $Gun
onready var mega_gun := $MegaGun
onready var hurt_box := $HurtBox
onready var animation_player := $AnimationPlayer
onready var animated_sprite := $AnimatedSprite
onready var screen_size := get_viewport_rect().size
onready var player_extents = $CollisionShape2D.shape.extents

var _min_pos_x := 0.0
var _min_pos_y := 0.0
var _max_pos_x := 0.0
var _max_pos_y := 0.0


func _ready() -> void:
	_min_pos_x = player_extents.x
	_min_pos_y = player_extents.y
	_max_pos_x = screen_size.x - player_extents.x
	_max_pos_y = screen_size.y - player_extents.y


func _process(delta: float) -> void:
	_process_movement(delta)
	_process_fire()


func revive(pos: Vector2) -> void:
	position = pos
	start_timed_invincibility()


func start_timed_invincibility():
	animation_player.play("invincible")


func die() -> void:
	# TODO Spawn explosion
	emit_signal("died")
	queue_free()


func _process_movement(delta: float) -> void:
	var velocity = SPEED * Input.get_vector(
		"move_left",
		"move_right",
		"move_up", 
		"move_down"
	)
	_move(velocity, delta)


func _process_fire() -> void:
	if not Input.is_action_pressed("fire"):
		if mega_gun.is_powered_up():
			mega_gun.prepare()
		return
	
	if not mega_gun.is_powered_up():
		gun.shoot(Vector2.UP)
		return
	
	if mega_gun.shoot():
		emit_signal("mega_gun_shot")


func _move(velocity: Vector2, delta: float) -> void:
	position += velocity * delta
	position.x = clamp(position.x, _min_pos_x, _max_pos_x)
	position.y = clamp(position.y, _min_pos_y, _max_pos_y)


func _on_HurtBox_hurt(who: Area2D) -> void:
	if who.has_method("explode"):
		who.explode()
	die()


func _on_Player_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickups"):
		area.pick_up()
