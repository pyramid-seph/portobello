class_name BattleEnemyData
extends Resource


@export var _enemy_name: String
@export var _texture: Texture2D
@export_range(1, 999, 1, "hide_slider") var _initial_hp: int = 1
@export_range(1, 999, 1, "hide_slider") var _initial_mp: int = 1
@export_range(1, 999, 1, "hide_slider") var _attack: int = 1
@export_range(1, 999, 1, "hide_slider") var _defense: int = 1
@export_range(1, 999, 1, "hide_slider") var _speed: int = 1
@export var _actions: Array[EnemyCommand]


func get_enemy_name() -> String:
	return _enemy_name


func get_texture() -> Texture2D:
	return _texture


func get_initial_hp() -> int:
	return _initial_hp


func get_initial_mp() -> int:
	return _initial_mp


func get_attack() -> int:
	return _attack


func get_defense() -> int:
	return _defense


func get_speed() -> int:
	return _speed


func get_actions() -> Array[EnemyCommand]:
	return _actions
