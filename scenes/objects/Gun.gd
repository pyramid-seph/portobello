extends Position2D


signal cooldown_ended

export(PackedScene) var Bullet
export var bullet_speed = 80
export var cooldown = 1.0


func _ready():
	$CooldownTimer.start(cooldown)


func __spawn_bullet(direction):
	var bullet = Bullet.instance()
	bullet.position = global_position
	bullet.direction = direction
	bullet.speed = bullet_speed
	$"/root".add_child(bullet)


func shoot(direction):
	if not $CooldownTimer.is_stopped():
		return false
	
	__spawn_bullet(direction)
	$CooldownTimer.start(cooldown)
	return true


func _on_CooldownTimer_timeout():
	emit_signal("cooldown_ended")
