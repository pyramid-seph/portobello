extends Node


export(PackedScene) var player

onready var world = $World


func _ready() -> void:
	randomize()
	var new_player = _instantiate_player()


func _instantiate_player():
	var new_player = player.instance()
	new_player.position = $World/StartPosition.position
	new_player.connect("died", self, "_on_Player_died")
	world.add_child(new_player)
	return new_player


func _on_Player_died():
	yield(get_tree().create_timer(3, false), "timeout")
	_instantiate_player()
