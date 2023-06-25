extends Node2D


@onready var _world = $World
@onready var _player = $World/Player
@onready var _wave_manager = $WaveManager
@onready var _ufo_shoot_manager = $UfoShootManager

func _ready() -> void:
	_ufo_shoot_manager.initialize(_world, _player)
	_wave_manager.start(_world, _player)
