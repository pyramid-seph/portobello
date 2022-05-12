extends Node


export(PackedScene) var player

onready var world = $World
onready var mega_gun_flash := $Interface/MegaGunFlash
onready var player_start_position = $World/StartPosition.position


func _ready() -> void:
	randomize()
	_instantiate_player()


func _instantiate_player() -> void:
	var new_player = player.instance()
	new_player.position = player_start_position
	new_player.connect("died", self, "_on_Player_died")
	new_player.connect("mega_gun_shot", mega_gun_flash, "_on_Player_mega_gun_shot")
	world.add_child(new_player)


func _on_Player_died() -> void:
	yield(get_tree().create_timer(3, false), "timeout")
	_instantiate_player()
