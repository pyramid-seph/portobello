extends Area2D

export var speed: float= 0.0
export var direction: Vector2= Vector2.ZERO


func _init() -> void:
	set_as_toplevel(true)


func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_VisibilityNotifier2D_viewport_exited(_viewport: Viewport) -> void:
	queue_free()


func _on_area_entered(_area: Area2D) -> void:
	queue_free()
