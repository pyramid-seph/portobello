extends Node


onready var player = $World/Player


func _ready():
	randomize()
	yield(get_tree().create_timer(1.0, false), "timeout")
	player.revive($World/StartPosition.position)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
				player.start_timed_invincibility()
