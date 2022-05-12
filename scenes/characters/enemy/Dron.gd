extends Area2D

const SPEED: float = 48.0
const SCORE_POINTS: int = 10

export(PackedScene) var explosion : PackedScene
export var direction: Vector2 = Vector2.DOWN

onready var world = get_parent()
onready var gun = $Gun


func _process(delta: float) -> void:
	position += direction * SPEED * delta


func explode() -> void:
	var new_explosion = explosion.instance()
	new_explosion.global_position = global_position
	world.add_child(new_explosion)
	queue_free()


func kill(killer: Node) -> void:
	if killer and killer.has_method("add_points_to_score"):
		killer.add_points_to_score(SCORE_POINTS)
	explode()
	queue_free()


func _on_VisibilityNotifier2D_viewport_exited(_viewport : Viewport) -> void:
	queue_free()


func _on_Gun_cooldown_ended() -> void:
	gun.shoot(Vector2.DOWN)


func _on_Dron_area_entered(area: Area2D):
	kill(area)
