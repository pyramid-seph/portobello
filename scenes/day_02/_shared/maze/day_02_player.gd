extends Area2D


var _maze: TileMap
var _curr_dir: Vector2i = Vector2i.ZERO
var _candidate_curr: Vector2i = Vector2i.ZERO
var _next_input: Vector2i

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _timer := $Timer as Timer


func _ready() -> void:
	_maze = get_parent() as TileMap


func _physics_process(delta: float) -> void:
	if not _timer.is_stopped():
		return
	else:
		_timer.start()
	
	var candidate_works := _candidate_curr != Vector2i.ZERO and _maze.get_cell_source_id(0, _map_pos() + _candidate_curr) == -1
	var curr_works = _maze.get_cell_source_id(0, _map_pos() + _curr_dir) == -1
	if candidate_works:
		print("candidate_works")
		_curr_dir = _candidate_curr
	elif not candidate_works and not curr_works:
		print("NO")
		_curr_dir = Vector2i.ZERO
	else:
		print("curr_works")
	var next_map_pos := _map_pos() + _curr_dir
	position = _maze.map_to_local(next_map_pos)
	
	match _curr_dir:
		Vector2i.UP:
			_animated_sprite.rotation_degrees = 90.0
			_animated_sprite.flip_h = true
			_animated_sprite.flip_v = false
		Vector2i.LEFT:
			_animated_sprite.rotation_degrees = 0.0
			_animated_sprite.flip_h = true
			_animated_sprite.flip_v = false
		Vector2i.RIGHT:
			_animated_sprite.rotation_degrees = 0.0
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false
		Vector2i.DOWN:
			_animated_sprite.rotation_degrees = 90.0
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = true
	
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


func _snap_pos() -> void:
	position = _maze.map_to_local(_map_pos())


func _map_pos() -> Vector2i:
	return _maze.local_to_map(position)
