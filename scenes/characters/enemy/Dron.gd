extends Area2D

const SPEED = 48
const SCORE = 10
const DIRECTION = Vector2.DOWN

export(PackedScene) var explosion : PackedScene

onready var world = get_parent()
onready var gun = $Gun


func _process(delta):
	position += DIRECTION * SPEED * delta


func explode():
	var new_explosion = explosion.instance()
	new_explosion.global_position = global_position
	world.add_child(new_explosion)
	queue_free()


func kill():
	PlayerData.score += SCORE
	explode()
	queue_free()


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()


func _on_Gun_cooldown_ended():
	gun.shoot(Vector2.DOWN)


func _on_area_entered(_area):
	kill()
