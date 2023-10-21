extends Node2D


signal ate_regular_treat
signal ate_super_treat
signal dying
signal died

enum Day02PlayerState {
	ALIVE,
	DYING,
	DEAD,
}

const Maze = preload("res://scenes/day_02/_shared/maze/maze.gd")

const SPEED: float = 40.0
const INPUT_TOLERANCE: float = 0.4

@export_group("Debug", "_debug")
@export var _debug_is_invincible: bool:
	get:
		return _debug_is_invincible and OS.is_debug_build()

var _candidate_dir: Vector2i
var is_movement_allowed := false
var _curr_dir: Vector2i
var _state: Day02PlayerState:
	set(value):
		_state = value
		_on_state_set()
var _next_valid_dirs: Array[Vector2i]
var _origin_local_pos: Vector2

@onready var _is_ready := true
@onready var _target_local_pos: Vector2 = position:
	set(value):
		_origin_local_pos = _target_local_pos
		_target_local_pos = value
		_on_target_local_pos_set()
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _maze := get_parent() as Maze


func _ready() -> void:
	_on_visibility_changed()
	if not _maze:
		queue_free()
		print("Player must be a direct children of a maze. queue_free() was called on the player.")
		return


func _physics_process(delta: float) -> void:
	if not _is_dead():
		_move(delta)


func _process(_delta: float) -> void:
	_read_input()
	$Node/Sprite2D2.global_position = _maze.to_global(_target_local_pos)
	$Node/Sprite2D.global_position = _maze.to_global(_origin_local_pos)
	$Node/Sprite2D.rotation_degrees = _animated_sprite.rotation_degrees
	$Node/Sprite2D.flip_h = _animated_sprite.flip_h
	$Node/Sprite2D.flip_v = _animated_sprite.flip_v
	queue_redraw()


func _draw() -> void:
	draw_line(Vector2.ZERO, _candidate_dir * 16, Color.RED, 2)
	draw_line(Vector2(-2, 8), Vector2(2, 8), Color.MEDIUM_SEA_GREEN, 2)
	draw_line(Vector2(-2, -8), Vector2(2, -8), Color.MEDIUM_SEA_GREEN, 2)
	draw_line(Vector2(-8, -2), Vector2(-8, 2), Color.MEDIUM_SEA_GREEN, 2)
	draw_line(Vector2(8, -2), Vector2(8, 2), Color.MEDIUM_SEA_GREEN, 2)


func teleport(map_pos: Vector2i) -> void:
	_curr_dir = Vector2i.ZERO
	_candidate_dir = Vector2i.ZERO
	position = _maze.map_to_local(map_pos)
	_target_local_pos = position
	_calculate_next_target()


func reset(map_pos: Vector2i) -> void:
	teleport(map_pos)
	_animated_sprite.rotation_degrees = 0.0
	_animated_sprite.flip_h = false
	_animated_sprite.flip_v = false
	is_movement_allowed = false
	_state = Day02PlayerState.ALIVE
	visible = true


func revive(map_pos: Vector2i) -> void:
	if _is_dead():
		reset(map_pos)
		is_movement_allowed = true


func die() -> void:
	if not _is_dead() and not _debug_is_invincible:
		_state = Day02PlayerState.DYING
		Utils.vibrate_joy()
		dying.emit()


func _is_dead() -> bool:
	return _state == Day02PlayerState.DYING or _state == Day02PlayerState.DYING


func _calculate_next_target() -> void:
	var target_map_pos: Vector2i = _maze.local_to_map(_target_local_pos)
	var next_target_map_pos: Vector2i = target_map_pos + _curr_dir
	if not _maze.is_empty_tile(next_target_map_pos):
		next_target_map_pos = target_map_pos
	_target_local_pos = _maze.map_to_local(next_target_map_pos)


func _read_input() -> void:
	if _is_dead() or not is_movement_allowed:
		_candidate_dir = Vector2i.ZERO
		return
	
	var input_vector := Input.get_vector(
			"move_left",
			"move_right",
			"move_up",
			"move_down"
	)
	var direction := Vector2i.ZERO
	if input_vector != Vector2.ZERO:
		if input_vector.abs().max_axis_index() == Vector2i.AXIS_X:
			direction.x = 1 if input_vector.x > 0 else -1
			direction.y = 0
		else:
			direction.x = 0
			direction.y = 1 if input_vector.y > 0 else -1
	_candidate_dir = direction


func _move(delta_time: float) -> void:
	if not _maze or not is_movement_allowed:
		_candidate_dir = Vector2.ZERO
		return
	
	if _curr_dir == Vector2i.ZERO or position == _target_local_pos:
		if _candidate_dir in _next_valid_dirs:
			_curr_dir = _candidate_dir
			_calculate_next_target()
		else:
			_curr_dir = Vector2i.ZERO
			_candidate_dir = Vector2.ZERO
			return
	elif _curr_dir + _candidate_dir == Vector2i.ZERO:
		_curr_dir = _candidate_dir
		_target_local_pos = _origin_local_pos
	
	var distance_budget: float = SPEED * delta_time
	# It is safe to assume that tile_size.x == tile_size.y
	#  because I'm using square tiles.
	var tile_size: float = _maze.tile_set.tile_size.x
	var max_iterations: int = ceili(distance_budget / tile_size)
	var distance_to_target: float = position.distance_to(_target_local_pos)
	if distance_to_target < distance_budget:
		max_iterations += 1
	
	for i in range(max_iterations):
		position = position.move_toward(_target_local_pos, distance_budget)
		distance_budget = maxf(distance_budget - distance_to_target, 0.0)
		distance_to_target = position.distance_to(_target_local_pos)
		if position == _target_local_pos:
			if _candidate_dir in _next_valid_dirs:
				_curr_dir = _candidate_dir
				_candidate_dir = Vector2i.ZERO
			_calculate_next_target()
			if position == _target_local_pos:
				_curr_dir = Vector2i.ZERO
				break
	
	_candidate_dir = Vector2i.ZERO
	_update_sprite_direction()


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
		Vector2i.RIGHT:
			_animated_sprite.rotation_degrees = 0.0
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false


func _on_state_set() -> void:
	if not _is_ready:
		return
	
	var new_animation := "dying" if _is_dead() else "default"
	if _animated_sprite.animation != new_animation:
		_animated_sprite.play(new_animation)


func _on_target_local_pos_set() -> void:
	_next_valid_dirs.clear()
	if not _is_ready:
		return
	
	var target_map_pos: Vector2i = _maze.local_to_map(_target_local_pos)
	var surrounding_empty_cells: Array[Vector2i] = \
			_maze.get_surrounding_empty_cells(target_map_pos)
	for empty_cell_map_pos in surrounding_empty_cells:
		_next_valid_dirs.append(empty_cell_map_pos - target_map_pos)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("treats"):
		area.visible = false
		ate_regular_treat.emit()
	if area.is_in_group("super_treats"):
		area.visible = false
		ate_super_treat.emit()


func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == "dying":
		visible = false
		died.emit()


func _on_visibility_changed() -> void:
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
