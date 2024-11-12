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

const SFX_PLAYER_DIE = preload("res://audio/sfx/sfx_day_02_player_die.wav")
const SFX_PLAYER_EAT_TREAT = preload("res://audio/sfx/sfx_day_02_player_eat_treat.wav")
const SFX_PLAYER_EAT_SUPER_TREAT = preload("res://audio/sfx/sfx_day_02_player_eat_super_treat.wav")

const SPEED: float = 40.0
const MAX_DIR_PRESSED_SEC: float = 0.15
const CORNERING_ZONE_SQRD_LENGHT: float = pow(4.0, 2.0)

@export_group("Debug", "_debug")
@export var _debug_is_invincible: bool:
	get:
		return _debug_is_invincible and OS.is_debug_build()
@export var _debug_show_move_lines: bool:
	get:
		return _debug_show_move_lines and OS.is_debug_build()
@export var _debug_show_target_and_origin: bool:
	get:
		return _debug_show_target_and_origin and OS.is_debug_build()
@export var _debug_show_dir_duration: bool:
	get:
		return _debug_show_dir_duration and OS.is_debug_build()

var is_movement_allowed := false

var _last_dir_input: Vector2i
var _dir_pressed_sec: float
var _candidate_dir: Vector2i
var _curr_dir: Vector2i
var _state: Day02PlayerState:
	set(value):
		_state = value
		_on_state_set()
var _next_valid_dirs: Array[Vector2i]
var _origin_valid_dirs: Array[Vector2i]
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
		Log.d("Player must be a direct children of a maze. queue_free() was called on the player.")
		queue_free()


func _physics_process(delta: float) -> void:
	if not _is_dead():
		_move(delta)


func _process(delta: float) -> void:
	_read_input(delta)


func teleport(map_pos: Vector2i) -> void:
	_curr_dir = Vector2i.ZERO
	_candidate_dir = Vector2i.ZERO
	_last_dir_input = Vector2i.ZERO
	_dir_pressed_sec = 0
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
		SoundManager.play_sound(SFX_PLAYER_DIE)
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


func _track_input_pressed(direction_pressed: Vector2i,  delta: float) -> void:
	if direction_pressed == Vector2i.ZERO:
		_last_dir_input = Vector2i.ZERO
		_dir_pressed_sec = 0
	elif _last_dir_input == direction_pressed:
		_dir_pressed_sec = minf(_dir_pressed_sec + delta, MAX_DIR_PRESSED_SEC)
	else:
		_last_dir_input = direction_pressed
		_dir_pressed_sec = 0


func _read_input(delta: float) -> void:
	if _is_dead() or not is_movement_allowed:
		_candidate_dir = Vector2i.ZERO
		_last_dir_input = Vector2i.ZERO
		_dir_pressed_sec = 0
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
	_track_input_pressed(direction, delta)


func _take_the_corner_if_possible() -> void:
	if _dir_pressed_sec >= MAX_DIR_PRESSED_SEC: 
		return
	
	var dist_sqrd_to_target: float = position.distance_squared_to(_target_local_pos)
	var dist_sqrd_to_origin: float = position.distance_squared_to(_origin_local_pos)
	var is_in_cornering_zone: bool = position != _target_local_pos and \
		(dist_sqrd_to_origin <= CORNERING_ZONE_SQRD_LENGHT or \
		dist_sqrd_to_target <= CORNERING_ZONE_SQRD_LENGHT)
	if is_in_cornering_zone:
		var candidate_dir_is_perpendicular: bool = \
			_curr_dir != Vector2i.ZERO and \
			is_zero_approx(Vector2(_curr_dir).dot(_candidate_dir))
		if candidate_dir_is_perpendicular:
			var is_closer_to_origin: bool = dist_sqrd_to_origin < dist_sqrd_to_target
			var corner_to_origin: bool = is_closer_to_origin and \
				_candidate_dir in _origin_valid_dirs
			var corner_to_target: bool = not is_closer_to_origin and \
				_candidate_dir in _next_valid_dirs
			if corner_to_origin:
				_target_local_pos = _origin_local_pos
			if corner_to_origin or corner_to_target:
				position = _target_local_pos
				_curr_dir = _candidate_dir
				_calculate_next_target()
		_candidate_dir = Vector2i.ZERO


func _move(delta_time: float) -> void:
	if not _maze or not is_movement_allowed:
		_candidate_dir = Vector2.ZERO
		return
	elif _curr_dir == Vector2i.ZERO:
		if _candidate_dir in _next_valid_dirs:
			_curr_dir = _candidate_dir
			_candidate_dir = Vector2i.ZERO
			_calculate_next_target()
		else:
			_curr_dir = Vector2i.ZERO
			_candidate_dir = Vector2i.ZERO
			return
	elif _curr_dir + _candidate_dir == Vector2i.ZERO:
		_curr_dir = _candidate_dir
		_target_local_pos = _origin_local_pos
		_candidate_dir = Vector2i.ZERO
	
	var distance_budget: float = SPEED * delta_time
	while not is_zero_approx(distance_budget):
		_take_the_corner_if_possible()
		var old_pos: Vector2 = position
		position = position.move_toward(_target_local_pos, distance_budget)
		var distance_moved: float = old_pos.distance_to(position)
		distance_budget = maxf(distance_budget - distance_moved, 0.0)
		if position == _target_local_pos:
			if _candidate_dir in _next_valid_dirs:
				_curr_dir = _candidate_dir
				_candidate_dir = Vector2i.ZERO
			_calculate_next_target()
			if position == _target_local_pos:
				_curr_dir = Vector2i.ZERO
				_candidate_dir = Vector2i.ZERO
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
	_origin_valid_dirs.clear()
	
	if not _is_ready:
		return
	
	var target_map_pos: Vector2i = _maze.local_to_map(_target_local_pos)
	var surrounding_empty_cells: Array[Vector2i] = \
			_maze.get_surrounding_empty_cells(target_map_pos)
	for empty_cell_map_pos: Vector2i in surrounding_empty_cells:
		_next_valid_dirs.append(empty_cell_map_pos - target_map_pos)
	var origin_map_pos: Vector2i = _maze.local_to_map(_origin_local_pos)
	surrounding_empty_cells = _maze.get_surrounding_empty_cells(origin_map_pos)
	for empty_cell_map_pos: Vector2i in surrounding_empty_cells:
		_origin_valid_dirs.append(empty_cell_map_pos - origin_map_pos)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("treats"):
		SoundManager.play_sound(SFX_PLAYER_EAT_TREAT)
		area.visible = false
		ate_regular_treat.emit()
	if area.is_in_group("super_treats"):
		SoundManager.play_sound(SFX_PLAYER_EAT_SUPER_TREAT)
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
