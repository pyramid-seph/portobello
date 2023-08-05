extends Node
### Note: "grid" methods use not centered cells: the origin of cell is the top-left
### corner instead of the center as is the case with tile map cells.

const Player = preload("res://scenes/day_01/player/day_01_player.gd")

const OUT_OF_SCREEN_POS: Vector2 = Vector2(-100, 100)

@export var _tile_map: TileMap
@export var _player_node_path: NodePath
@export var _origin: Marker2D
@export var _tile_size: Vector2i: # Tile map does not expose its tile_size :(
	set(value):
		_tile_size = value
		_tile_offset = Vector2(_tile_size / 2)

# Tile map uses the center of a cell as its local position.
# Furniture sprites are not centered. We use this
# offset to place them correctly.
var _tile_offset: Vector2 # Depends on _tile_size.

@export_group("Furniture")
@export var _large_table: Area2D
@export var _large_couch: Area2D
@export var _small_couch_facing_left: Area2D
@export var _small_couch_facing_right: Area2D
@export var _small_table_00: Area2D
@export var _small_table_01: Area2D

@export_subgroup("Tile Sizes", "_tile_size")
@export var _tile_size_large_table: Vector2i
@export var _tile_size_large_couch: Vector2i
@export var _tile_size_small_couch: Vector2i
@export var _tile_size_small_table: Vector2i

var _all_furniture: Array[Area2D]:
	get:
		if _all_furniture.is_empty():
			_all_furniture = [
				_large_table,
				_large_couch,
				_small_couch_facing_left,
				_small_couch_facing_right,
				_small_table_00,
				_small_table_01
			]
		return _all_furniture

@onready var _player := get_node(_player_node_path) as Player
# Tile map position is (0, 0). Because of this,
# unlike the original code, the top left wall piece
# (which is the origin position for this algorythm)
# is not in (0, 0) and, thus, we need to calculate
# its tile pos on _ready(). 
@onready var _origin_tile_pos: Vector2i = global_to_map(_origin.global_position)


func place_furniture_outside() -> void:
	for furniture in _all_furniture:
		furniture.call_deferred("set_position", OUT_OF_SCREEN_POS)


func place_large_table(grid_pos: Vector2i) -> void:
	_large_table.call_deferred("set_position", map_to_local_grid_pos(grid_pos))


func place_large_couch(grid_pos: Vector2i) -> void:
	_large_couch.call_deferred("set_position", map_to_local_grid_pos(grid_pos))


func place_small_couch_facing_left(grid_pos: Vector2i) -> void:
	_small_couch_facing_left.call_deferred("set_position", map_to_local_grid_pos(grid_pos))


func place_small_couch_facing_right(grid_pos: Vector2i) -> void:
	_small_couch_facing_right.call_deferred("set_position", map_to_local_grid_pos(grid_pos))


func place_small_table_00(grid_pos: Vector2i) -> void:
	_small_table_00.call_deferred("set_position", map_to_local_grid_pos(grid_pos))


func place_small_table_01(grid_pos: Vector2i) -> void:
	_small_table_01.call_deferred("set_position", map_to_local_grid_pos(grid_pos))


func get_large_table_tile_size() -> Vector2i:
	return _tile_size_large_table


func get_large_couch_tile_size() -> Vector2i:
	return _tile_size_large_couch


func get_small_couch_tile_size() -> Vector2i:
	return _tile_size_small_couch


func get_small_table_tile_size() -> Vector2i:
	return _tile_size_small_table


func grid_rect_of_player_head() -> Rect2i:
	return Rect2i(
		global_to_grid(_player.get_head_global_postion()),
		Vector2i.ONE
	)


func grid_rect_of_player_tail() -> Rect2i:
	return Rect2i(
		global_to_grid(_player.get_tail_global_postion()),
		Vector2i.ONE
	)


func grid_rect_of_large_table() -> Rect2i:
	return Rect2i(
		global_to_grid(_large_table.global_position),
		get_large_table_tile_size()
	)


func grid_rect_of_large_couch() -> Rect2i:
	return Rect2i(
		global_to_grid(_large_couch.global_position),
		get_large_couch_tile_size()
	)


func grid_rect_of_small_couch_left() -> Rect2i:
	return Rect2i(
		global_to_grid(_small_couch_facing_left.global_position),
		get_small_couch_tile_size()
	)


func grid_rect_of_small_couch_right() -> Rect2i:
	return Rect2i(
		global_to_grid(_small_couch_facing_right.global_position),
		get_small_couch_tile_size()
	)


func grid_rect_of_small_table_00() -> Rect2i:
	return Rect2i(
		global_to_grid(_small_table_00.global_position),
		get_small_table_tile_size()
	)


func grid_rect_of_small_table_01() -> Rect2i:
	return Rect2i(
		global_to_grid(_small_table_01.global_position),
		get_small_table_tile_size()
	)


func map_pos_of_player_head() -> Vector2i:
	return global_to_map(_player.get_head_global_postion())


func map_pos_of_player_tail() -> Vector2i:
	return global_to_map(_player.get_tail_global_postion())


func global_to_map(pos: Vector2) -> Vector2i:
	return local_to_map(_tile_map.to_local(pos))


func local_to_map(pos: Vector2) -> Vector2i:
	return _tile_map.local_to_map(pos)


func map_to_local(pos: Vector2i) -> Vector2:
	return _tile_map.map_to_local(pos)


func map_to_global(pos: Vector2i) -> Vector2:
	return _tile_map.to_global(map_to_local(pos))


func global_to_grid(pos: Vector2) -> Vector2i:
	return global_to_map(pos) - _origin_tile_pos


func map_to_local_grid_pos(pos: Vector2i) -> Vector2:
	return map_to_local(pos + _origin_tile_pos) - _tile_offset
