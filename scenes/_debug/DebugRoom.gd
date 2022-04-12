extends Node

export var enable_autofire = false

onready var player = $World/Player


func _ready():
	randomize()
	player.is_auto_fire_enabled = enable_autofire
	player.revive($World/StartPosition.position)
