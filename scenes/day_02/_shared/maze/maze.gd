extends TileMap

const TILE_SIZE: int = 16

@onready var _is_ready := true
@onready var _player_start_marker: Node2D = $PlayerStartPos
@onready var _player_respawn_marker: Node2D = $PlayerRespawnPos
@onready var _player: Node2D = $Day02Player


func _ready() -> void:
	_player.position = _player_start_marker.position
	$Day02Enemy.teleport(local_to_map(_player_respawn_marker.position))
	await get_tree().create_timer(3.0, false).timeout
	$Day02Enemy.scare()


func is_ready() -> bool:
	return _is_ready


func is_empty_tile(map_pos: Vector2i) -> bool:
	return get_cell_source_id(0, map_pos) == -1


func get_surrounding_empty_cells(map_pos: Vector2i) -> Array[Vector2i]:
	var surrounding_cells = get_surrounding_cells(map_pos)
	return surrounding_cells.filter(func(item):
		return is_empty_tile(item)
	)
