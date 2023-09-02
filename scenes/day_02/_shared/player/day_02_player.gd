extends Node2D

const SPEED: float = 50.0 # 4 pixels every 0.08 seconds (OG game -> 1 frame = 0.08s)
const INPUT_TOLERANCE: float = 0.4
const TILE_SIZE: int = 16

var _curr_dir: Vector2i
var _candidate_curr: Vector2i
var _target_position: Vector2

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _timer := $Timer as Timer
@onready var _maze := get_parent() as TileMap


func _physics_process(delta: float) -> void:
	if _candidate_curr == Vector2i.ZERO and _curr_dir == Vector2i.ZERO:
		return
	
	var candidate_works := _candidate_curr != Vector2i.ZERO and _maze.get_cell_source_id(0, _map_pos() + _candidate_curr) == -1
	var curr_works = _maze.is_empty_tile(_map_pos() + _curr_dir)
	if candidate_works:
		_curr_dir = _candidate_curr
	elif not candidate_works and not curr_works:
		_curr_dir = Vector2i.ZERO
	var next_map_pos := _map_pos() + _curr_dir
	
	_update_sprite_direction()
	
	_candidate_curr = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		_candidate_curr = Vector2i.LEFT
	elif event.is_action_pressed("move_up"):
		_candidate_curr = Vector2i.UP
	elif event.is_action_pressed("move_down"):
		_candidate_curr = Vector2i.DOWN
	elif event.is_action_pressed("move_right"):
		_candidate_curr = Vector2i.RIGHT


func _get_target_pos() -> Vector2:
	var target_pos: Vector2 = Vector2.ZERO
	return target_pos


func _update_sprite_direction() -> void:
	match _curr_dir:
		Vector2i.UP:
			_animated_sprite.rotation_degrees = 90.0
			_animated_sprite.flip_h = true
			_animated_sprite.flip_v = false
		Vector2i.LEFT:
			_animated_sprite.rotation_degrees = 0.0
			_animated_sprite.flip_h = true
			_animated_sprite.flip_v = false
		Vector2i.DOWN:
			_animated_sprite.rotation_degrees = 90.0
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = true
		_:
			_animated_sprite.rotation_degrees = 0.0
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false


func _map_pos() -> Vector2i:
	return _maze.local_to_map(position)
