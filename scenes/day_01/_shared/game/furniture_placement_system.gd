extends Node


const TileMapHelper = preload("res://scenes/day_01/_shared/game/day_01_tile_map_helper.gd")

const LARGE_TABLE_GRID_POS := Vector2i(12, 13)

@export var _max_tries: int
@export var _tile_map_helper_path: NodePath

@onready var _house_helper: TileMapHelper = get_node(_tile_map_helper_path)


func place_furniture(obstacle_course_type: Day01LevelSettings.ObstacleCourseType) -> void:
	match obstacle_course_type:
		Day01LevelSettings.ObstacleCourseType.NONE:
			place_furniture_none()
		Day01LevelSettings.ObstacleCourseType.RANDOM:
			place_furniture_random()
		Day01LevelSettings.ObstacleCourseType.DEFAULT:
			place_furniture_default()


func place_furniture_none() -> void:
	_house_helper.place_furniture_outside()


func place_furniture_default() -> void:
	_house_helper.place_large_table(LARGE_TABLE_GRID_POS)
	_house_helper.place_large_couch(Vector2i(2, 2))
	_house_helper.place_small_couch_facing_right(Vector2i(1, 8))
	_house_helper.place_small_couch_facing_left(Vector2i(13, 1))
	_house_helper.place_small_table_00(Vector2i(19, 0))
	_house_helper.place_small_table_01(Vector2i(8, 4))


func place_furniture_random() -> void:
	var large_table_rect := _rect2i(_house_helper.get_large_table_tile_size())
	var large_couch_rect := _rect2i(_house_helper.get_large_couch_tile_size())
	var small_couch_right_rect := _rect2i(_house_helper.get_small_couch_tile_size())
	var small_couch_left_rect := _rect2i(_house_helper.get_small_couch_tile_size())
	var small_table_00_rect := _rect2i(_house_helper.get_small_table_tile_size())
	var small_table_01_rect := _rect2i(_house_helper.get_small_table_tile_size())
	
	large_table_rect.position = LARGE_TABLE_GRID_POS
	large_couch_rect.position = _get_random_large_couch_grid_pos()
	
	var head_rect := _house_helper.grid_rect_of_player_head()
	var tail_rect := _house_helper.grid_rect_of_player_tail()
	
	var tries: int = 0
	while tries <= _max_tries:
		small_couch_left_rect.position = _get_random_small_couch_grid_pos()
		if small_couch_left_rect.intersects(large_table_rect) or \
				small_couch_left_rect.intersects(large_couch_rect) or \
				small_couch_left_rect.intersects(head_rect) or \
				small_couch_left_rect.intersects(tail_rect):
			tries += 1
		else:
			break

	while tries <= _max_tries:
		small_couch_right_rect.position = _get_random_small_couch_grid_pos()
		if small_couch_right_rect.intersects(large_table_rect) or \
				small_couch_right_rect.intersects(large_couch_rect) or \
				small_couch_right_rect.intersects(small_couch_left_rect) or \
				small_couch_right_rect.intersects(head_rect) or \
				small_couch_right_rect.intersects(tail_rect):
			tries += 1
		else:
			break

	while tries <= _max_tries:
		small_table_00_rect.position = _get_random_small_table_grid_pos()
		if small_table_00_rect.intersects(large_table_rect) or \
				small_table_00_rect.intersects(large_couch_rect) or \
				small_table_00_rect.intersects(small_couch_left_rect) or \
				small_table_00_rect.intersects(small_couch_right_rect) or \
				small_table_00_rect.intersects(head_rect) or \
				small_table_00_rect.intersects(tail_rect):
			tries += 1
		else:
			break

	while tries <= _max_tries:
		small_table_01_rect.position = _get_random_small_table_grid_pos()
		if small_table_01_rect.intersects(large_table_rect) or \
				small_table_01_rect.intersects(large_couch_rect) or \
				small_table_01_rect.intersects(small_couch_left_rect) or \
				small_table_01_rect.intersects(small_couch_right_rect) or \
				small_table_01_rect.intersects(small_table_00_rect) or \
				small_table_01_rect.intersects(head_rect) or \
				small_table_01_rect.intersects(tail_rect):
			tries += 1
		else:
			break
	
	if tries > _max_tries:
		_use_fallback_placement()
	else:
		_house_helper.place_large_table(large_table_rect.position)
		_house_helper.place_large_couch(large_couch_rect.position)
		_house_helper.place_small_couch_facing_left(small_couch_left_rect.position)
		_house_helper.place_small_couch_facing_right(small_couch_right_rect.position)
		_house_helper.place_small_table_00(small_table_00_rect.position)
		_house_helper.place_small_table_01(small_table_01_rect.position)


func _rect2i(pos: Vector2i) -> Rect2i:
	return Rect2i(Vector2i.ZERO, pos)


func _get_random_large_couch_grid_pos() -> Vector2i:
	var grid_pos := Vector2i.ZERO
	grid_pos.x = randi() % 5 + 2
	if grid_pos.x >= 4:
		if randi() % 2 == 0:
			grid_pos.y = randi() % 2 + 10
		else:
			grid_pos.y = 2
	else:
		grid_pos.y = randi() % 11 + 2
	return grid_pos


func _get_random_small_couch_grid_pos() -> Vector2i:
	var grid_pos := Vector2i.ZERO
	grid_pos.x = randi() % 17 + 1
	grid_pos.y = randi() % 14 + 1
	if grid_pos.x in range(3, 12) and grid_pos.y in range(3, 10):
		if randi() % 2 == 0:
			grid_pos.x = randi() % 2 + 1
		else:
			grid_pos.x = randi() % 5 + 13
		
		if grid_pos.x <= 2:
			grid_pos.y = randi() % 14 + 1
		else:
			grid_pos.y = randi() % 7 + 1
	elif grid_pos.x > 12 and grid_pos.y >= 8:
		grid_pos.y = randi() % 7 + 1
	return grid_pos


func _get_random_small_table_grid_pos() -> Vector2i:
	var grid_pos := Vector2i.ZERO
	grid_pos.x = randi() % 18 + 1
	grid_pos.y = randi() % 16 + 1
	if grid_pos.x in range(5, 12) and grid_pos.y in range(5, 10):
		if randi() % 2 == 0:
			grid_pos.x = randi() % 5 + 1
		else:
			grid_pos.x = randi() % 5 + 14
			
		if grid_pos.x <= 5:
			grid_pos.y = randi() % 16 + 1
		else:
			grid_pos.y = randi() % 9 + 1
	elif grid_pos.x > 12 and grid_pos.y > 9:
		grid_pos.y = randi() % 9 + 1
	return grid_pos


func _use_fallback_placement() -> void:
	_house_helper.place_large_table(LARGE_TABLE_GRID_POS)
	
	if randi() % 2 == 0:
		_house_helper.place_large_couch(Vector2i(2, 7))
		_house_helper.place_small_couch_facing_right(Vector2i(1, 1))
		_house_helper.place_small_couch_facing_left(Vector2i(13, 6))
		_house_helper.place_small_table_00(Vector2i(2, 14))
		_house_helper.place_small_table_01(Vector2i(17, 4))
	else:
		_house_helper.place_large_couch(Vector2i(2, 7))
		_house_helper.place_small_couch_facing_right(Vector2i(17, 4))
		_house_helper.place_small_couch_facing_left(Vector2i(11, 4))
		_house_helper.place_small_table_00(Vector2i(15, 1))
		_house_helper.place_small_table_01(Vector2i(11, 1))
