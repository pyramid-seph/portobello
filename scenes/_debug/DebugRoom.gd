extends Node


export(PackedScene) var player

onready var world = $World
onready var megaGunFlash := $Interface/MegaGunFlash


func _ready() -> void:
	randomize()
	var new_player = _instantiate_player()


func _instantiate_player():
	var new_player = player.instance()
	new_player.position = $World/StartPosition.position
	new_player.connect("died", self, "_on_Player_died")
	new_player.connect("mega_gun_shot", megaGunFlash, "_on_Player_mega_gun_shot")
	world.add_child(new_player)
	return new_player


func _on_Player_died():
	yield(get_tree().create_timer(3, false), "timeout")
	_instantiate_player()
