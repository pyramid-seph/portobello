extends Node2D

signal ate_regular_treat
signal ate_super_treat
signal died

const Maze = preload("res://scenes/day_02/_shared/maze/maze.gd")

const SPEED: float = 8# 50.0 # 4 pixels every 0.08 seconds (OG game -> 1 frame = 0.08s)
const INPUT_TOLERANCE: float = 0.4

var is_movement_allowed := false
var _curr_dir: Vector2i
var _candidate_dir: Vector2i

@onready var _is_ready := true
@onready var _target_local_pos: Vector2 = position
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _timer := $Timer as Timer
@onready var _maze := get_parent() as Maze


func _ready() -> void:
	if not _maze:
		print("Player must be a children of a maze.")
		return


func _draw() -> void:
	var rect := Vector2i(_target_local_pos - position + Vector2(-8,-8))
	draw_rect(Rect2(rect, Vector2(16,16)), Color(Color.YELLOW, 0.4))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		_candidate_dir = Vector2i.LEFT
	elif event.is_action_pressed("move_up"):
		_candidate_dir = Vector2i.UP
	elif event.is_action_pressed("move_down"):
		_candidate_dir = Vector2i.DOWN
	elif event.is_action_pressed("move_right"):
		_candidate_dir = Vector2i.RIGHT
	_pick_next_movement_3()


func _process(_delta: float) -> void:
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not is_dead():
		_move(delta)


func teleport(map_pos: Vector2i) -> void:
	position = _maze.map_to_local(map_pos)
	_target_local_pos = position
	#_pick_next_movement_2()


func reset(map_pos: Vector2i) -> void:
	_timer.stop()
	teleport(map_pos)
	is_movement_allowed = true
#	is_movement_allowed = false
	# TODO Reset dead state, set animatiomn to the default one.


func is_dead() -> bool:
	return false


func _move(delta: float) -> void:
	if not is_movement_allowed:
		return
	
#	if _curr_dir == Vector2i.ZERO:
#		_pick_next_movement_2()
#	_pick_next_movement_2()

	var remaining_distance: float = SPEED * delta
	while remaining_distance > 0 and not is_zero_approx(remaining_distance):
		if _curr_dir == Vector2i.ZERO:
			break
		
		var old_pos: Vector2 = position
		_move_towards_target(remaining_distance)
		remaining_distance -= old_pos.distance_to(position)
		var arrived_to_target: bool = position == _target_local_pos
		if arrived_to_target:
			break
#		if arrived_to_target:
#			_pick_next_movement_2()
	_update_sprite_direction()
	_candidate_dir = Vector2.ZERO
	$Label.text = str(_map_pos())


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


func _pick_next_movement_3() -> void:
	if _candidate_dir == Vector2i.ZERO and _curr_dir == Vector2i.ZERO:
		return
	
	var arrived_to_destination := position != _target_local_pos
	if arrived_to_destination and _candidate_dir + _curr_dir == Vector2i.ZERO:
		if _map_pos() == _maze.local_to_map(_target_local_pos):
			_target_local_pos = _maze.map_to_local(_map_pos() + _candidate_dir)
		else:
			_target_local_pos = _maze.map_to_local(_map_pos())
		_curr_dir = _candidate_dir
	else:
		_pick_next_movement_2()
		


func _pick_next_movement_2() -> void:
	if _candidate_dir == Vector2i.ZERO and _curr_dir == Vector2i.ZERO:
		return

	var curr_map_pos := _map_pos()
	var candidate_works := _candidate_dir != Vector2i.ZERO and \
			_maze.is_empty_tile(curr_map_pos + _candidate_dir)
	var curr_works = _maze.is_empty_tile(curr_map_pos + _curr_dir)
	if candidate_works:
		_curr_dir = _candidate_dir
	elif not candidate_works and not curr_works:
		_curr_dir = Vector2i.ZERO
	var new_target_map_pos := curr_map_pos + _curr_dir
	_target_local_pos = _maze.map_to_local(new_target_map_pos)


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


func _map_pos() -> Vector2i:
	return _maze.local_to_map(position)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("treats"):
		print("chomped a treat")
		area.visible = false
		ate_regular_treat.emit()
	if area.is_in_group("super_treats"):
		print("chomped a super treat")
		area.visible = false
		ate_super_treat.emit()
