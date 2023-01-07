@tool
extends Node2D

@export var color: Color = Color8(255, 0, 255):
	set(value):
		color = value
		queue_redraw()
	get:
		return color


func _draw():
	draw_rect(get_viewport_rect(), color)
