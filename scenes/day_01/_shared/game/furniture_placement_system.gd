extends Node


const Treat = preload("res://scenes/day_01/_shared/treat.tscn")
const Player = preload("res://scenes/day_01/player/day_01_player.gd")

const LARGE_TABLE_TILE_POS: Vector2i = Vector2i(12, 13)
const OUT_OF_SCREEN_POS: Vector2 = Vector2(-100, 100)

@export var _tile_map: TileMap
@export var _player_node_path: NodePath
@export var _max_tries: int
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

# Tile map position is (0, 0). Because of this,
# unlike the original code, the top left wall piece
# (which is the origin position for this algorythm)
# is not in (0, 0) and, thus, we need to calculate
# its tile pos on _ready(). 
# TODO We should consider use (4, 4) as the position of the top left wall piece.
var _origin_tile_pos: Vector2i

@onready var _origin := $TopLeft as Marker2D
@onready var _player := get_node(_player_node_path) as Player


func _ready() -> void:
	_origin_tile_pos = _local_to_map(_origin.position)


func place_furniture(obstacle_course_type: Day01LevelSettings.ObstacleCourseType) -> void:
	match obstacle_course_type:
		Day01LevelSettings.ObstacleCourseType.NONE:
			place_furniture_none()
		Day01LevelSettings.ObstacleCourseType.RANDOM:
			place_furniture_random()
		Day01LevelSettings.ObstacleCourseType.DEFAULT:
			place_furniture_default()


func place_furniture_none() -> void:
	_large_table.call_deferred("set_position", OUT_OF_SCREEN_POS)
	_large_couch.call_deferred("set_position", OUT_OF_SCREEN_POS)
	_small_couch_facing_left.call_deferred("set_position", OUT_OF_SCREEN_POS)
	_small_couch_facing_right.call_deferred("set_position", OUT_OF_SCREEN_POS)
	_small_table_00.call_deferred("set_position", OUT_OF_SCREEN_POS)
	_small_table_01.call_deferred("set_position", OUT_OF_SCREEN_POS)


func place_furniture_default() -> void:
	# We assume that player's head is at (9, 9) and tail is at (7, 9).
	var l_table_temp := Rect2i(LARGE_TABLE_TILE_POS, _tile_size_large_table)
	var l_couch_temp := Rect2i(Vector2i(2, 2), _tile_size_large_couch)
	var s_couch_right_temp := Rect2i(Vector2i(1, 8), _tile_size_small_couch)
	var s_couch_left_temp := Rect2i(Vector2i(13, 1), _tile_size_small_couch)
	var s_table_00_temp := Rect2i(Vector2i(19, 0), _tile_size_small_table)
	var s_table_01_temp := Rect2i(Vector2i(8, 4), _tile_size_small_table)
	_large_table.call_deferred("set_position", _map_to_furniture_pos(l_table_temp.position))
	_large_couch.call_deferred("set_position", _map_to_furniture_pos(l_couch_temp.position))
	_small_couch_facing_left.call_deferred("set_position", _map_to_furniture_pos(s_couch_left_temp.position))
	_small_couch_facing_right.call_deferred("set_position", _map_to_furniture_pos(s_couch_right_temp.position))
	_small_table_00.call_deferred("set_position", _map_to_furniture_pos(s_table_00_temp.position))
	_small_table_01.call_deferred("set_position", _map_to_furniture_pos(s_table_01_temp.position))


func place_furniture_random() -> void:
	var head_rect := Rect2i(
		_global_to_map(_player.get_head_global_postion()) - _origin_tile_pos,
		 Vector2i.ONE
	)
	
	var tail_rect := Rect2i(
		_global_to_map(_player.get_tail_global_postion()) - _origin_tile_pos,
		 Vector2i.ONE
	)
	
	var tries: int = 0
	var l_table_temp := Rect2i(Vector2i.ZERO, _tile_size_large_table)
	var l_couch_temp := Rect2i(Vector2i.ZERO, _tile_size_large_couch)
	var s_couch_right_temp := Rect2i(Vector2i.ZERO, _tile_size_small_couch)
	var s_couch_left_temp := Rect2i(Vector2i.ZERO, _tile_size_small_couch)
	var s_table_00_temp := Rect2i(Vector2i.ZERO, _tile_size_small_table)
	var s_table_01_temp := Rect2i(Vector2i.ZERO, _tile_size_small_table)
	
	l_table_temp.position = LARGE_TABLE_TILE_POS
	
	l_couch_temp.position = _lc_cool()
	
	# small couch facing left
	while tries <= _max_tries:
		s_couch_left_temp.position = _sc_cool()
		if s_couch_left_temp.intersects(l_table_temp) or \
				s_couch_left_temp.intersects(l_couch_temp) or \
				s_couch_left_temp.intersects(head_rect) or \
				s_couch_left_temp.intersects(tail_rect):
			tries += 1
		else:
			break

	# small couch facing right
	while tries <= _max_tries:
		s_couch_right_temp.position = _sc_cool()
		if s_couch_right_temp.intersects(l_table_temp) or \
				s_couch_right_temp.intersects(l_couch_temp) or \
				s_couch_right_temp.intersects(s_couch_left_temp) or \
				s_couch_right_temp.intersects(head_rect) or \
				s_couch_right_temp.intersects(tail_rect):
			tries += 1
		else:
			break

	# small table 0
	while tries <= _max_tries:
		s_table_00_temp.position = _st_cool()
		if s_table_00_temp.intersects(l_table_temp) or \
				s_table_00_temp.intersects(l_couch_temp) or \
				s_table_00_temp.intersects(s_couch_left_temp) or \
				s_table_00_temp.intersects(s_couch_right_temp) or \
				s_table_00_temp.intersects(head_rect) or \
				s_table_00_temp.intersects(tail_rect):
			tries += 1
		else:
			break

	# small table 2
	while tries <= _max_tries:
		s_table_01_temp.position = _st_cool()
		if s_table_01_temp.intersects(l_table_temp) or \
				s_table_01_temp.intersects(l_couch_temp) or \
				s_table_01_temp.intersects(s_couch_left_temp) or \
				s_table_01_temp.intersects(s_couch_right_temp) or \
				s_table_01_temp.intersects(s_table_00_temp) or \
				s_table_01_temp.intersects(head_rect) or \
				s_table_01_temp.intersects(tail_rect):
			tries += 1
		else:
			break
	
	print("TRIES: %s" % tries)
	if tries > _max_tries:
		_use_fallback_placement()
	else:
		_large_table.call_deferred("set_position", _map_to_furniture_pos(l_table_temp.position))
		_large_couch.call_deferred("set_position", _map_to_furniture_pos(l_couch_temp.position))
		_small_couch_facing_left.call_deferred("set_position", _map_to_furniture_pos(s_couch_left_temp.position))
		_small_couch_facing_right.call_deferred("set_position", _map_to_furniture_pos(s_couch_right_temp.position))
		_small_table_00.call_deferred("set_position", _map_to_furniture_pos(s_table_00_temp.position))
		_small_table_01.call_deferred("set_position", _map_to_furniture_pos(s_table_01_temp.position))


func _lc_cool() -> Vector2i:
	var tile_pos := Vector2i.ZERO
	tile_pos.x = randi() % 5 + 2
	if tile_pos.x >= 4:
		if randi() % 2 == 0:
			tile_pos.y = randi() % 2 + 10
		else:
			tile_pos.y = 2
	else:
		tile_pos.y = randi() % 11 + 2
	return tile_pos


func _sc_cool() -> Vector2i:
	var tile_pos := Vector2i.ZERO
	tile_pos.x = randi() % 17 + 1
	tile_pos.y = randi() % 14 + 1
	if tile_pos.x in range(3, 12) and tile_pos.y in range(3, 10):
		if randi() % 2 == 0:
			tile_pos.x = randi() % 2 + 1
		else:
			tile_pos.x = randi() % 5 + 13
		
		if tile_pos.x <= 2:
			tile_pos.y = randi() % 14 + 1
		else:
			tile_pos.y = randi() % 7 + 1
	elif tile_pos.x > 12 and tile_pos.y >= 8:
		tile_pos.y = randi() % 7 + 1
	return tile_pos


func _st_cool() -> Vector2i:
	var tile_pos := Vector2i.ZERO
	tile_pos.x = randi() % 18 + 1
	tile_pos.y = randi() % 16 + 1
	if tile_pos.x in range(5, 12) and tile_pos.y in range(5, 10):
		if randi() % 2 == 0:
			tile_pos.x = randi() % 5 + 1
		else:
			tile_pos.x = randi() % 5 + 14
			
		if tile_pos.x <= 5:
			tile_pos.y = randi() % 16 + 1
		else:
			tile_pos.y = randi() % 9 + 1
	elif tile_pos.x > 12 and tile_pos.y > 9:
		tile_pos.y = randi() % 9 + 1
	return tile_pos


func _use_fallback_placement() -> void:
	var l_table_temp := Rect2i(Vector2i.ZERO, _tile_size_large_table)
	var l_couch_temp := Rect2i(Vector2i.ZERO, _tile_size_large_couch)
	var s_couch_right_temp := Rect2i(Vector2i.ZERO, _tile_size_small_couch)
	var s_couch_left_temp := Rect2i(Vector2i.ZERO, _tile_size_small_couch)
	var s_table_00_temp := Rect2i(Vector2i.ZERO, _tile_size_small_table)
	var s_table_01_temp := Rect2i(Vector2i.ZERO, _tile_size_small_table)
	
	if randi() % 2 == 0:
		l_table_temp.position = LARGE_TABLE_TILE_POS
		l_couch_temp.position = Vector2i(2, 7)
		s_couch_right_temp.position = Vector2i(1, 1)
		s_couch_left_temp.position = Vector2i(13, 6)
		s_table_00_temp.position = Vector2i(2, 14)
		s_table_01_temp.position = Vector2i(17, 4)
	else:
		l_table_temp.position = LARGE_TABLE_TILE_POS
		l_couch_temp.position = Vector2i(2, 7)
		s_couch_right_temp.position = Vector2i(17, 4)
		s_couch_left_temp.position = Vector2i(11, 4)
		s_table_00_temp.position = Vector2i(15, 1)
		s_table_01_temp.position = Vector2i(11, 1)
	
	_large_table.call_deferred("set_position", _map_to_furniture_pos(l_table_temp.position))
	_large_couch.call_deferred("set_position", _map_to_furniture_pos(l_couch_temp.position))
	_small_couch_facing_left.call_deferred("set_position", _map_to_furniture_pos(s_couch_left_temp.position))
	_small_couch_facing_right.call_deferred("set_position", _map_to_furniture_pos(s_couch_right_temp.position))
	_small_table_00.call_deferred("set_position", _map_to_furniture_pos(s_table_00_temp.position))
	_small_table_01.call_deferred("set_position", _map_to_furniture_pos(s_table_01_temp.position))


func _global_to_map(pos: Vector2) -> Vector2i:
	return _local_to_map(_tile_map.to_local(pos))


func _local_to_map(pos: Vector2) -> Vector2i:
	return _tile_map.local_to_map(pos)


func _map_to_local(pos: Vector2i) -> Vector2:
	return _tile_map.map_to_local(pos)


func _map_to_furniture_pos(pos: Vector2i) -> Vector2:
	return _map_to_local(pos + _origin_tile_pos) - _tile_offset
