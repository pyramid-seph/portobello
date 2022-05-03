extends Node


onready var player = $World/Player


func _ready():
	randomize()
	player.revive($World/StartPosition.position)
