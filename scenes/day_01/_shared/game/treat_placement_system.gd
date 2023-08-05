extends Node


const Treat = preload("res://scenes/day_01/_shared/treat.tscn")
const Player = preload("res://scenes/day_01/player/day_01_player.gd")

@export var _tile_map: TileMap
@export var _world: Node2D
@export var _player_node_path: NodePath
@export var _max_tries: int

@export_group("Debug", "_debug")
@export var _debug_enable_log: bool

var _top_left_map_pos: Vector2i
var _top_right_map_pos: Vector2i
var _bottom_left_map_pos: Vector2i
var _treat_weak_ref: WeakRef

@onready var _top_left := $TopLeft as Marker2D
@onready var _top_right := $TopRight as Marker2D
@onready var _bottom_left := $BottomLeft as Marker2D
@onready var _collision_detector := $ShapeCast2D as ShapeCast2D
@onready var _player := get_node(_player_node_path) as Player

func _ready() -> void:
	_top_left_map_pos = _global_to_map(_top_left.global_position)
	_top_right_map_pos = _global_to_map(_top_right.global_position)
	_bottom_left_map_pos = _global_to_map(_bottom_left.global_position)


## Places a treat at a random position inside the house.
## This uses physics to check whether a candidate
## position collides with something. Make sure
## to await until the next frame when it makes
## sense (per example, after placing the furniture)
func spawn_treat_random() -> void:
	_free_curr_treat()
	var treat := Treat.instantiate()
	treat.global_position = _randomize_placement()
	_world.call_deferred("add_child", treat)
	_treat_weak_ref = weakref(treat)


func _free_curr_treat() -> void:
	if _treat_weak_ref:
		var ref = _treat_weak_ref.get_ref() as Node
		if ref:
			ref.queue_free()


func _randomize_placement() -> Vector2:
	var tries: int = 0
	var map_pos: Vector2
	_print_debug("\n")
	while tries < _max_tries:
		map_pos.x = randi_range(_top_left_map_pos.x, _top_right_map_pos.x)
		map_pos.y = randi_range(_top_left_map_pos.y, _bottom_left_map_pos.y)
		
		if _collides_with_furniture(map_pos) or \
				_collides_with_player_head(map_pos) or \
				_collides_with_start_position(map_pos):
			tries += 1
			continue
		else:
			break
	if tries >= _max_tries:
		_print_debug("Exceeded retries. Placing at the neck pos.")
		map_pos = _get_first_trunc_part_map_pos()
	return _map_to_global(map_pos)


func _collides_with_furniture(map_pos: Vector2i) -> bool:
	_collision_detector.target_position = Vector2.ZERO
	_collision_detector.global_position = _map_to_global(map_pos)
	_collision_detector.force_update_transform()
	_collision_detector.force_shapecast_update()
	if _collision_detector.is_colliding():
		var area = _collision_detector.get_collider(0)
		_print_debug("Collides with: %s: %s -> %s." % [area.name, map_pos, _collision_detector.global_position])
	else:
		_print_debug("No collision with furniture detected: %s -> %s." % [map_pos, _collision_detector.global_position])
	return _collision_detector.is_colliding()


func _collides_with_player_head(map_pos: Vector2i) -> bool:
	if  map_pos == _global_to_map(_player.get_head_global_postion()):
		_print_debug("Collides with the head. :(")
	else:
		_print_debug("Does NOT collide with the head.")
	# We could have just relied on the shapecast, but this way 
	# (I think) we can avoid awaiting for a process frame
	# when a treat placement is attempted after the player eats a treat.
	return map_pos == _global_to_map(_player.get_head_global_postion())


func _collides_with_start_position(map_pos: Vector2i) -> bool:
	if map_pos == _global_to_map(_player.get_global_start_position()):
		_print_debug("collides with start pos.")
	else:
		_print_debug("Does NOT collide with start pos.")	
	return map_pos == _global_to_map(_player.get_global_start_position())


func _print_debug(msg: String) -> void:
	if OS.is_debug_build() and _debug_enable_log:
		print(msg)


func _global_to_map(pos: Vector2) -> Vector2i:
	return _local_to_map(_tile_map.to_local(pos))


func _local_to_map(pos: Vector2) -> Vector2i:
	return _tile_map.local_to_map(pos)


func _map_to_local(pos: Vector2i) -> Vector2:
	return _tile_map.map_to_local(pos)


func _map_to_global(pos: Vector2i) -> Vector2:
	return _tile_map.to_global(_map_to_local(pos))


func _get_first_trunc_part_map_pos() -> Vector2i:
	return _global_to_map(_player.get_first_trunk_part_global_postion())
