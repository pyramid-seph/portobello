extends Node2D


signal died

@export var _hp: int = 1
@export var _phase_2_at_hp: int = 1
@export var _phase_3_at_hp: int = 1
@export var Explosion: PackedScene

var _is_dead: bool = false
var _player: Day03Player

@onready var block_spawner := $BlockSpawner
@onready var regular_gun := $Gun as Gun
@onready var laser_balls_gun := $LaserBallsGun
@onready var alien_hologram := $AlienHologram


func initialize(player: Day03Player) -> void:
	_player = player


func is_dead() -> bool:
	return _is_dead


func _on_weakness_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
