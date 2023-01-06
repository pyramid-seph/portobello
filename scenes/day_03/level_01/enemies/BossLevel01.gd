extends Node2D

func _process(delta):
	position += Vector2.DOWN * 48.0 * delta
