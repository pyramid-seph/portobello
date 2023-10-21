@tool
extends Node2D


signal chomped
signal dead

const Maze = preload("res://scenes/day_02/_shared/maze/maze.gd")

enum MazeEnemyState {
	CHASING,
	SCARED,
	NOT_SO_SCARED,
	DEAD,
}

const SCARE_DURATION_SEC: float = 6.4
const NOT_SO_SCARED_DELAY_SEC: float = 4.4
const DYING_DURATION_SEC: float = 1.0

@export var speed: float = 40.0
@export var _texture_0: Texture2D:
	set(value):
		_texture_0 = value
		_on_textures_set()
@export var _texture_1: Texture2D:
	set(value):
		_texture_1 = value
		_on_textures_set()
@export var _z_index_default: int
@export var _z_index_dead: int

var is_halt: bool = true:
	set(value):
		is_halt = value
		_on_is_halt_set()
var _curr_dir: Vector2i
var _target_local_pos: Vector2
var _state: MazeEnemyState = MazeEnemyState.CHASING:
	set(value):
		_state = value
		_on_state_set()

@onready var _is_ready := true
@onready var _maze := get_parent() as Maze
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _scare_timer := $ScareTimer as Timer
@onready var _not_so_scared_delay_timer := $NotSoScaredDelayTimer as Timer
@onready var _dying_timer := $DyingTimer as Timer


func _ready() -> void:
	_on_is_halt_set()
	_on_textures_set()
	if not Engine.is_editor_hint():
		_on_state_set()
		if _maze:
			await _maze.ready
			_pick_next_movement()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or is_dead():
		return
	
	_move(delta)


func teleport(map_pos: Vector2i) -> void:
	if _maze:
		position = _maze.map_to_local(map_pos)
		_pick_next_movement()


func reset(map_pos: Vector2i) -> void:
	visible = true
	_scare_timer.stop()
	_not_so_scared_delay_timer.stop()
	_dying_timer.stop()
	_state = MazeEnemyState.CHASING
	is_halt = true
	teleport(map_pos)


func get_scared() -> void:
	if not is_dead():
		_state = MazeEnemyState.SCARED
		_scare_timer.start(SCARE_DURATION_SEC)
		_not_so_scared_delay_timer.start(NOT_SO_SCARED_DELAY_SEC)


func is_dead() -> bool:
	return _state == MazeEnemyState.DEAD


func _is_scared() -> bool:
	return _state == MazeEnemyState.SCARED or \
			_state == MazeEnemyState.NOT_SO_SCARED


func _move(delta_time: float) -> void:
	if not _maze or is_halt or _curr_dir == Vector2i.ZERO:
		return
	
	var distance_budget: float = speed * delta_time
	var distance_to_target: float = position.distance_to(_target_local_pos)
	if is_zero_approx(distance_to_target): # TODO
		position = _target_local_pos
		_pick_next_movement()
		return
	
	var iterations: int = 1
	if distance_budget > distance_to_target:
		iterations = ceili(distance_budget / distance_to_target)
	for i in range(iterations):
		position = position.move_toward(_target_local_pos, distance_budget)
		distance_budget = maxf(distance_budget - distance_to_target, 0.0)
		distance_to_target = position.distance_to(_target_local_pos)
		if is_zero_approx(distance_to_target):
			_pick_next_movement()


func _pick_next_movement() -> void:
	if not _maze:
		return
	
	var candidates: Array[Vector2i] = _maze.get_surrounding_empty_cells(_map_pos())
	if candidates.is_empty():
		_curr_dir = Vector2i.ZERO
		_target_local_pos = _map_pos()
		return
	
	var curr_map_pos = _map_pos()
	var candidates_partition: Array = Utils.partition(candidates, func(candidate):
		var curr_dir_candidate: Vector2i = candidate - curr_map_pos
		return Vector2(_curr_dir).dot(curr_dir_candidate) == 0
	)
	var perpendicular_candidates: Array = candidates_partition[0]
	var parallel_candidates: Array = candidates_partition[1]
	var is_at_crossroad := !perpendicular_candidates.is_empty()
	
	var new_target_map_pos: Vector2i = Vector2i.ZERO
	if is_at_crossroad:
		new_target_map_pos = candidates.pick_random()
	elif parallel_candidates.size() == 1:
		new_target_map_pos = parallel_candidates[0]
	else:
		new_target_map_pos = curr_map_pos + _curr_dir
	_curr_dir = new_target_map_pos - _map_pos()
	_target_local_pos = _maze.map_to_local(new_target_map_pos)


func _map_pos() -> Vector2i:
	return _maze.local_to_map(position)


func _update_animation() -> void:
	var new_animation: String = "default"
	match _state:
		MazeEnemyState.DEAD:
			new_animation = "dead"
		MazeEnemyState.SCARED:
			new_animation = "scared"
		MazeEnemyState.NOT_SO_SCARED:
			new_animation = "not_so_scared"
	if _animated_sprite.animation != new_animation:
		_animated_sprite.play(new_animation)


func _die() -> void:
	if not is_dead() and _is_scared():
		_scare_timer.stop()
		_not_so_scared_delay_timer.stop()
		_dying_timer.start(DYING_DURATION_SEC)
		_state = MazeEnemyState.DEAD
		chomped.emit()


func _on_is_halt_set() -> void:
	if _is_ready and is_halt:
		_scare_timer.stop()
		_not_so_scared_delay_timer.stop()
		_dying_timer.stop()


func _on_textures_set() -> void:
	if _is_ready:
		var sprite_frames := _animated_sprite.sprite_frames
		sprite_frames.set_frame("default", 0, _texture_0)
		sprite_frames.set_frame("default", 1, _texture_1)
		sprite_frames.set_frame("not_so_scared", 0, _texture_0)


func _on_state_set() -> void:
	if not _is_ready:
		return
	z_index = _z_index_dead if _state == MazeEnemyState.DEAD else _z_index_default
	_update_animation()


func _on_not_so_scared_delay_timer_timeout() -> void:
	if not is_dead():
		_state = MazeEnemyState.NOT_SO_SCARED


func _on_scare_timer_timeout() -> void:
	if not is_dead():
		_state = MazeEnemyState.CHASING


func _on_dying_timer_timeout() -> void:
	visible = false
	dead.emit()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_halt:
		return
	
	var area_owner := area.get_parent()
	if _is_scared():
		_die()
	elif area_owner and area_owner.has_method("die"):
		area_owner.die()
