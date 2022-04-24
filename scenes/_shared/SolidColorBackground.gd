tool
extends Node2D

export(Color) var color = Color8(255, 0, 255)


func _draw():
	draw_rect(get_viewport_rect(), color)
