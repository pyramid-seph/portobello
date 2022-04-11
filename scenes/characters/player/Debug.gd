extends Node

onready var scene_tree = get_tree()
onready var player = get_parent()

func _ready():
	if not OS.is_debug_build(): 
		queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("debug_kill"):
		player.die()
		scene_tree.set_input_as_handled()
	elif event.is_action_pressed("debug_revive"):
		player.revive(player.position)
		scene_tree.set_input_as_handled()
