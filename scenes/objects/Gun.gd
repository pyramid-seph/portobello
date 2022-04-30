extends Position2D

signal cooldown_ended

export(PackedScene) var Bullet
export var bullet_speed = 80
export var cooldown = 1.0

onready var _root = $"/root"
onready var _cooldown_timer = $CooldownTimer


func _ready():
	_cooldown_timer.start(cooldown)


func _spawn_bullet(direction: Vector2):
	var bullet = Bullet.instance()
	bullet.position = global_position
	bullet.direction = direction
	bullet.speed = bullet_speed
	_root.add_child(bullet)


func shoot(direction):
	if not _cooldown_timer.is_stopped():
		return false

	_spawn_bullet(direction)
	_cooldown_timer.start(cooldown)
	return true


func _on_CooldownTimer_timeout():
	emit_signal("cooldown_ended")
