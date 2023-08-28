extends Area2D


enum MazeEnemyState {
	CHASING,
	SCARED,
	DEAD,
}

@export var speed: float = 50.0 # 4 pixels every 0.08 seconds (OG game -> 1 frame = 0.08s)

var _curr_dir: Vector2i
var _target_local_pos: Vector2
var _state: MazeEnemyState = MazeEnemyState.CHASING

@onready var _is_ready := true
@onready var _maze := get_parent() as TileMap
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if not _maze:
		queue_free()
		print("Maze enemies must be direct children of mazes. queue_free() was called on this enemy.")
		return
	
	await _maze.ready
	_pick_next_movement()


func teleport(map_pos: Vector2i) -> void:
	position = _maze.map_to_local(map_pos)
	_pick_next_movement()


func _physics_process(delta: float) -> void:
	_move(delta)


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
