extends Node2D

signal chomped
signal dead(who: Node2D)

enum MazeEnemyState {
	CHASING,
	SCARED,
	NOT_SO_SCARED,
	DEAD,
}

const SCARE_DURATION_SEC: float = 6.4
const NOT_SO_SCARED_DELAY_SEC: float = 4.0

@export var speed: float = 50.0 # 4 pixels every 0.08 seconds (OG game -> 1 frame = 0.08s)

var _curr_dir: Vector2i
var _target_local_pos: Vector2
var _state: MazeEnemyState = MazeEnemyState.CHASING:
	set(value):
		_state = value
		_on_state_set()

@onready var _is_ready := true
@onready var _maze := get_parent() as TileMap
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _scare_timer: Timer = $ScareTimer
@onready var _not_so_scared_delay_timer: Timer = $NotSoScaredDelayTimer


func _ready() -> void:
	if not _maze:
		queue_free()
		print("Maze enemies must be direct children of mazes. queue_free() was called on this enemy.")
		return
	_on_state_set()
	await _maze.ready
	_pick_next_movement()


func _physics_process(delta: float) -> void:
	if not is_dead():
		_move(delta) # TODO implement halt for when level is beaten. Maybe a set_physics_process is enough


func teleport(map_pos: Vector2i) -> void:
	position = _maze.map_to_local(map_pos)
	_pick_next_movement()


func revive(map_pos: Vector2i) -> void:
	if is_dead(): # TODO delay revival here or on maze?
		visible = true
		_state = MazeEnemyState.CHASING
		teleport(map_pos)


func scare() -> void:
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
		dead.emit(self)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if _is_scared():
		_die()
	else:
		pass # TODO Kill the player
