extends Area2D

signal dead_enemy

const SPEED = 48
const SCORE = 10
const DIRECTION = Vector2.DOWN 


func _ready():
	$AnimatedSprite.play()


func _process(delta):
	position += DIRECTION * SPEED * delta


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()


func _on_StormyCloud_area_entered(_area):
	emit_signal("dead_enemy")
	queue_free()


func _on_Gun_cooldown_ended():
	$Gun.shoot(Vector2.DOWN)


func _on_area_entered(_area):
	PlayerData.score += SCORE
	queue_free()
