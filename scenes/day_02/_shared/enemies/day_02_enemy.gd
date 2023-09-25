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
const NOT_SO_SCARED_DELAY_SEC: float = 4.0

@export var speed: float = 50.0 # 4 pixels every 0.08 seconds (OG game -> 1 frame = 0.08s)
@export var _texture_0: Texture2D:
	set(value):
		_texture_0 = value
		_on_textures_set()
@export var _texture_1: Texture2D:
	set(value):
		_texture_1 = value
		_on_textures_set()

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


func _ready() -> void:
	_on_is_halt_set()
	
	if not Engine.is_editor_hint() and not _maze:
		queue_free()
		print("Maze enemies must be direct children of mazes. queue_free() was called on this enemy.")
		return
	_on_textures_set()
	if not Engine.is_editor_hint():
		_on_state_set()
		await _maze.ready
		_pick_next_movement()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or is_dead():
		return
	
	_move(delta)


func teleport(map_pos: Vector2i) -> void:
	position = _maze.map_to_local(map_pos)
	_pick_next_movement()


func reset(map_pos: Vector2i) -> void:
	visible = true
	_scare_timer.stop()
	_not_so_scared_delay_timer.stop()
	# Reset dead animation timer
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


func _move(delta: float) -> void:
	if is_halt:
		return
	var remaining_distance: float = speed * delta
	while remaining_distance > 0 and not is_zero_approx(remaining_distance):
		if _curr_dir == Vector2i.ZERO:
			break
		
		var old_pos: Vector2 = position
		_move_towards_target(remaining_distance)
		remaining_distance -= old_pos.distance_to(position)
		var arrived_to_target: bool = position == _target_local_pos
		if arrived_to_target:
			_pick_next_movement()


func _move_towards_target(distance: float) -> void:
	var new_pos: Vector2 = position
	match _curr_dir:
		Vector2i.LEFT:
			new_pos.x = maxf(new_pos.x - distance, _target_local_pos.x)
		Vector2i.RIGHT:
			new_pos.x = minf(new_pos.x + distance, _target_local_pos.x)
		Vector2i.UP:
			new_pos.y = maxf(new_pos.y - distance, _target_local_pos.y)
		Vector2i.DOWN:
			new_pos.y = minf(new_pos.y + distance, _target_local_pos.y)
	position = new_pos


func _pick_next_movement() -> void:
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
		_state = MazeEnemyState.DEAD
		chomped.emit()


func _on_is_halt_set() -> void:
	if not _is_ready:
		return
	if is_halt:
		_scare_timer.stop()
		_not_so_scared_delay_timer.stop()


func _on_textures_set() -> void:
	if _is_ready:
		var sprite_frames := _animated_sprite.sprite_frames
		sprite_frames.set_frame("default", 0, _texture_0)
		sprite_frames.set_frame("default", 1, _texture_1)
		sprite_frames.set_frame("not_so_scared", 0, _texture_0)


func _on_state_set() -> void:
	if not _is_ready:
		return
	_update_animation()


func _on_not_so_scared_delay_timer_timeout() -> void:
	if not is_dead():
		_state = MazeEnemyState.NOT_SO_SCARED


func _on_scare_timer_timeout() -> void:
	if not is_dead():
		_state = MazeEnemyState.CHASING


func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == "dead":
		visible = false
		dead.emit()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_halt:
		return
	
	if _is_scared():
		_die()
	elif area.has_method("die"):
		area.die()
