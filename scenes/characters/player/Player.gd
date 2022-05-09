extends Area2D

signal mega_gun_shot
signal died


const SPEED := 40.0

export(Resource) var player_data
export(PackedScene) var fall : PackedScene
export(PackedScene) var explosion : PackedScene

onready var gun := $Gun
onready var mega_gun := $MegaGun
onready var hurt_box := $HurtBox
onready var animation_player := $AnimationPlayer
onready var animated_sprite := $AnimatedSprite
onready var screen_size := get_viewport_rect().size
onready var player_extents = $CollisionShape2D.shape.extents
onready var world = get_parent()

var _min_pos_x := 0.0
var _min_pos_y := 0.0
var _max_pos_x := 0.0
var _max_pos_y := 0.0


func _ready() -> void:
	_min_pos_x = player_extents.x
	_min_pos_y = player_extents.y
	_max_pos_x = screen_size.x - player_extents.x
	_max_pos_y = screen_size.y - player_extents.y
	mega_gun.player_data = player_data
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
	_die()


func fall() -> void:
	var new_fall = fall.instance()
	new_fall.global_position = global_position
	world.add_child(new_fall)
	_die()


func add_points_to_score(points: int) -> void:
	player_data.score += points


func add_time_to_fly(time: float) -> void:
	pass


func power_up_by(points: int) -> void:
	player_data.power_up_count += 1


func _die() -> void:
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
	explode()


func _on_Player_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickups"):
		area.pick_up(self)
