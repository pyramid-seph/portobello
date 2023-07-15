extends Node


const Treat = preload("res://scenes/day_01/_shared/treat.tscn")
const Player = preload("res://scenes/day_01/player/day_01_player.gd")

@export var _tile_map: TileMap
@export var _world: Node2D
@export var _player_node_path: NodePath
@export var _max_tries: int

var _top_left_tile_pos: Vector2i
var _top_right_tile_pos: Vector2i
var _bottom_left_tile_pos: Vector2i

@onready var _top_left := $TopLeft as Marker2D
@onready var _top_right := $TopRight as Marker2D
@onready var _bottom_left := $BottomLeft as Marker2D
@onready var _collision_detector := $ShapeCast2D as ShapeCast2D
@onready var _player := get_node(_player_node_path) as Player


func _ready() -> void:
	_top_left_tile_pos = _local_to_map(_top_left.position)
	_top_right_tile_pos = _local_to_map(_top_right.position)
	_bottom_left_tile_pos = _local_to_map(_bottom_left.position)


## Places a treat at a random position inside the house.
## This uses physics to check whether a candidate
## position collides with something. Make sure
## to await until the next frame when it makes
## sense (per example, after placing the furniture)
func spawn_treat_random() -> void:
	var treat = Treat.instantiate()
	treat.global_position = _randomize_placement()
	_world.call_deferred("add_child", treat)


func _randomize_placement() -> Vector2:
	var tries: int = 0
	var tile_pos: Vector2
	while tries <= _max_tries:
		tile_pos.x = randi_range(_top_left_tile_pos.x, _top_right_tile_pos.x)
		tile_pos.y = randi_range(_top_left_tile_pos.y, _bottom_left_tile_pos.y)
		
		if _collides_with_furniture(tile_pos) or _collides_with_player_head(tile_pos):
			tries += 1
			continue
		else:
			break
	if tries >= _max_tries:
		tile_pos = _get_first_trunc_part_tile_pos()
	return _tile_map.to_global(_map_to_local(tile_pos))


func _collides_with_furniture(tile_pos: Vector2i) -> bool:
	_collision_detector.global_position = _map_to_global(tile_pos)
	_collision_detector.force_update_transform()
	_collision_detector.target_position = Vector2.ZERO
	_collision_detector.force_shapecast_update()
	if OS.is_debug_build():
		if _collision_detector.is_colliding():
			var area = _collision_detector.get_collider(0)
			print("Collides with: %s. Retrying treat placement." % area.name)
		else:
			print("No collision detected")
	return _collision_detector.is_colliding()


func _collides_with_player_head(tile_pos: Vector2i) -> bool:
	# We could have just relied on the shapcast, but this way 
	# (I think) we can avoid awaiting for a process frame
	# when a treat placement is attempted after the player eats a treat.
	var local_head_pos := _tile_map.to_local(_player.get_head_global_postion())
	return _local_to_map(local_head_pos) == tile_pos


func _global_to_map(pos: Vector2) -> Vector2i:
	return _local_to_map(_tile_map.to_local(pos))


func _local_to_map(pos: Vector2) -> Vector2i:
	return _tile_map.local_to_map(pos)


func _map_to_local(pos: Vector2i) -> Vector2:
	return _tile_map.map_to_local(pos)


func _map_to_global(pos: Vector2i) -> Vector2:
	return _tile_map.to_global(_map_to_local(pos))


func _get_first_trunc_part_tile_pos() -> Vector2i:
	var first_trunk_part_global_pos = _player.get_first_trunk_part_global_postion()
	var first_trunk_part_tile_map_local_pos = \
			_tile_map.to_local(first_trunk_part_global_pos)
	return _local_to_map(first_trunk_part_tile_map_local_pos)
