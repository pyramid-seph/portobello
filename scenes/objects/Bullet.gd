extends Area2D

export var speed := 0.0
export var direction := Vector2.ZERO


func _init():
	set_as_toplevel(true)


func _ready():
	connect("area_entered", self, "_on_area_entered")


func _process(delta):
	position += direction * speed * delta


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()


func _on_area_entered(_area):
	queue_free()
