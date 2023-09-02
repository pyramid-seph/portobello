extends TileMap


const Day02Enemy = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")
const Day02Player = preload("res://scenes/day_02/_shared/player/day_02_player.gd")

const TILE_SIZE: int = 16

@onready var _is_ready := true
@onready var _player_start_marker: Node2D = $PlayerStartPos
@onready var _player_respawn_marker: Node2D = $PlayerRespawnPos
@onready var _player: Day02Player = $Day02Player
@onready var _blue_ghost: Day02Enemy = $BlueGhost
@onready var _red_ghost: Day02Enemy = $RedGhost
@onready var _yellow_ghost: Day02Enemy = $YellowGhost


func _ready() -> void:
	_player.position = _player_start_marker.position
	_set_up_ghosts()


func is_ready() -> bool:
	return _is_ready


func is_empty_tile(map_pos: Vector2i) -> bool:
	return get_cell_source_id(0, map_pos) == -1


func get_surrounding_empty_cells(map_pos: Vector2i) -> Array[Vector2i]:
	var surrounding_cells = get_surrounding_cells(map_pos)
	return surrounding_cells.filter(func(item):
		return is_empty_tile(item)
	)


func _set_up_ghost(ghost: Day02Enemy) -> void:
	ghost.teleport(local_to_map(_player_respawn_marker.position))
	ghost.chomped.connect(_on_enemy_chomped)
	ghost.dead.connect(_on_enemy_dead)


func _set_up_ghosts() -> void:
	_set_up_ghost(_blue_ghost)
	_set_up_ghost(_red_ghost)
	_set_up_ghost(_yellow_ghost)


func _on_enemy_chomped() -> void:
	print("TODO: Inform game so it can update the score")


func _on_enemy_dead(killed: Node2D) -> void:
	get_tree().create_timer(3.0, false).timeout.connect(func():
		killed.revive(local_to_map(_player_respawn_marker.position))
	)
