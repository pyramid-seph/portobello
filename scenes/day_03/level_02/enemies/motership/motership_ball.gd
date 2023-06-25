@tool
extends Node2D

@export_color_no_alpha var color: Color = Color.MAGENTA:
	set(value):
		color = value
		_on_color_set()

@onready var ball_sprite = $BallSprite

@onready var _is_ready: bool = true


func _ready() -> void:
	_on_color_set()


func _on_color_set():
	if _is_ready:
		ball_sprite.modulate = color
