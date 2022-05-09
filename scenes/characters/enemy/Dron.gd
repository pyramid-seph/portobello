extends Area2D

const SPEED = 48
const SCORE_POINTS = 10
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


func kill(killer):
	if killer and killer.is_in_group("players"):
		killer.add_points_to_score(SCORE_POINTS)
	explode()
	queue_free()


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()


func _on_Gun_cooldown_ended():
	gun.shoot(Vector2.DOWN)


func _on_area_entered(area):
	kill(area)
