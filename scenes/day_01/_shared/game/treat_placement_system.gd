extends Node


const Treat = preload("res://scenes/day_01/_shared/items/treat.tscn")
const Player = preload("res://scenes/day_01/player/day_01_player.gd")
const TileMapHelper = preload("res://scenes/day_01/_shared/game/day_01_tile_map_helper.gd")

@export var _world: Node2D
@export var _player_node_path: NodePath
@export var _max_tries: int
@export var _tile_map_helper_path: NodePath

var _top_left_map_pos: Vector2i
var _top_right_map_pos: Vector2i
var _bottom_left_map_pos: Vector2i
var _treat_weak_ref: WeakRef

@onready var _top_left := $TopLeft as Marker2D
@onready var _top_right := $TopRight as Marker2D
@onready var _bottom_left := $BottomLeft as Marker2D
@onready var _collision_detector := $ShapeCast2D as ShapeCast2D
@onready var _player := get_node(_player_node_path) as Player
@onready var _house_helper: TileMapHelper = get_node(_tile_map_helper_path)

func _ready() -> void:
	_top_left_map_pos = _house_helper.global_to_map(_top_left.global_position)
	_top_right_map_pos = _house_helper.global_to_map(_top_right.global_position)
	_bottom_left_map_pos = _house_helper.global_to_map(_bottom_left.global_position)


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
	Log.d("\n")
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
		Log.d("Exceeded retries. Placing at the neck pos.")
		map_pos = _get_first_trunc_part_map_pos()
	return _house_helper.map_to_global(map_pos)


func _collides_with_furniture(map_pos: Vector2i) -> bool:
	_collision_detector.target_position = Vector2.ZERO
	_collision_detector.global_position = _house_helper.map_to_global(map_pos)
	_collision_detector.force_update_transform()
	_collision_detector.force_shapecast_update()
	if _collision_detector.is_colliding():
		var area = _collision_detector.get_collider(0)
		Log.d("Collides with: %s: %s -> %s." % [area.name, map_pos, _collision_detector.global_position])
	else:
		Log.d("No collision with furniture detected: %s -> %s." % [map_pos, _collision_detector.global_position])
	return _collision_detector.is_colliding()


func _collides_with_player_head(map_pos: Vector2i) -> bool:
	# I could have just relied on the shapecast, but this way 
	# (I think) awaiting for a process frame can be avoided
	# when a treat placement is attempted after the player eats a treat.
	var collision_detected := map_pos == _house_helper.global_to_map(_player.get_head_global_postion())
	if  collision_detected:
		Log.d("Collides with the head. :(")
	else:
		Log.d("Does NOT collide with the head.")
	return collision_detected


func _collides_with_start_position(map_pos: Vector2i) -> bool:
	var collision_detected := map_pos == _house_helper.global_to_map(_player.get_global_start_position())
	if collision_detected:
		Log.d("collides with start pos.")
	else:
		Log.d("Does NOT collide with start pos.")
	return collision_detected


func _get_first_trunc_part_map_pos() -> Vector2i:
	return _house_helper.global_to_map(_player.get_first_trunk_part_global_postion())
