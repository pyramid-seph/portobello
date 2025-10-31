extends CharacterBody2D


enum FacingDirection {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

const SlipperyFloorDetector = preload("res://scenes/day_ex/player/slippery_floor_detector.gd")
const ActionAreaDetector = preload("res://scenes/day_ex/player/action_area_detector.gd")

@export var speed: float = 33.33
@export_range(1.0, 3.0, 0.1) var slip_speed_multiplier: float = 2.0
@export_range(0.05, 1.0, 0.01) var slip_buffer_time_sec: float = 0.1

@export_group("Debug", "_debug")
@export var _debug_show_walking_time: bool:
	set(value):
		_debug_show_walking_time = value
		_on_debug_show_walking_time_set()
	get: 
		return OS.is_debug_build() and _debug_show_walking_time
@export var _debug_show_move_vectors: bool:
	get:
		return OS.is_debug_build() and _debug_show_move_vectors

var _buffered_input_dir: Vector2
var _is_iddle: bool = true
var _walking_time: float:
	set(value):
		_walking_time = value
		_on_walking_time_set()

@onready var _walking_time_label: Label = $WalkingTimeLabel
@onready var _action_area_detector: ActionAreaDetector = $ActionAreaDetector
@onready var _interact_sprite_2d: Sprite2D = $InteractSprite2D
@onready var _slippery_floor_detector: SlipperyFloorDetector = $SlipperyFloorDetector
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _slip_buffer_timer: Timer = $SlipBufferTimer

func _ready() -> void:
	_interact_sprite_2d.hide()
	_on_walking_time_set()
	_on_debug_show_walking_time_set()


func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = _get_input()
	var is_on_slippery_floor: bool = _slippery_floor_detector.is_on_slippery_floor()
	if is_on_slippery_floor:
		input_dir = _buffer_slip_dir(input_dir)
		_set_slip_velocity(input_dir)
	else:
		_reset_slip_buffer()
		_set_walk_velocity(input_dir)
	move_and_slide()
	
	var hit_a_wall: bool = true
	if not velocity.is_zero_approx():
		var wall_normal: Vector2 = \
				get_wall_normal() if is_on_wall() else Vector2.ZERO
		hit_a_wall = wall_normal.dot(velocity.normalized()) == -1
	
	if not hit_a_wall and not is_on_slippery_floor:
		_walking_time += delta
	
	var is_iddle: bool = (hit_a_wall or velocity.is_zero_approx()) or \
			(is_on_slippery_floor and input_dir == Vector2.ZERO)
	_update_animation_params(input_dir, is_iddle)
	
	if _debug_show_move_vectors:
		queue_redraw()


func _process(_delta: float) -> void:
	var movement_allows_interaction: bool = \
			not _slippery_floor_detector.is_on_slippery_floor() or \
			is_zero_approx(velocity.length_squared())
	_interact_sprite_2d.visible = movement_allows_interaction and \
			is_processing_unhandled_input() and \
			_action_area_detector.is_executable_action_area_detected()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		var movement_allows_interaction: bool = \
				not _slippery_floor_detector.is_on_slippery_floor() or \
				is_zero_approx(velocity.length_squared())
		if movement_allows_interaction and \
				_action_area_detector.execute_detected_action_area(self):
					get_viewport().set_input_as_handled()


func _draw() -> void:
	if is_on_wall():
		var wall_normal: Vector2 = get_wall_normal()
		draw_line(Vector2.ZERO, wall_normal * 15.0, Color.GREEN, 4.0)
	draw_line(Vector2.ZERO, get_real_velocity().normalized() * 15.0, Color.RED, 2.0)


func reset_walking_time() -> void:
	_walking_time = 0.0


func get_walking_time() -> float:
	return _walking_time


func teleport(new_global_position: Vector2, facing_direction: FacingDirection) -> void:
	global_position = new_global_position
	reset_physics_interpolation()
	velocity = Vector2.ZERO
	reset_walking_time()
	var direction: Vector2 = Vector2.LEFT
	match facing_direction:
		FacingDirection.LEFT:
			direction = Vector2.LEFT
		FacingDirection.RIGHT:
			direction = Vector2.RIGHT
		FacingDirection.UP:
			direction = Vector2.UP
		FacingDirection.DOWN:
			direction = Vector2.DOWN
	_update_animation_params(direction, true)


func _set_slip_velocity(input_dir: Vector2) -> void:
	if not is_processing_unhandled_input():
		velocity = Vector2.ZERO
		return
	
	var last_dir: Vector2 = get_real_velocity().normalized().round()
	if last_dir.is_zero_approx():
		if input_dir != last_dir and input_dir != Vector2.ZERO:
			last_dir = input_dir
		velocity = speed * slip_speed_multiplier * last_dir


func _set_walk_velocity(input_dir: Vector2) -> void:
	velocity = speed * input_dir


func _get_input() -> Vector2:
	if not is_processing_unhandled_input():
		return Vector2.ZERO
	elif Input.is_action_pressed("move_up"):
		return Vector2.UP
	elif Input.is_action_pressed("move_down"):
		return Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		return Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		return Vector2.RIGHT
	else:
		return Vector2.ZERO


func _update_animation_params(facing_dir: Vector2, is_idle: bool):
	_is_iddle = is_idle
	if facing_dir != Vector2.ZERO:
		_animation_tree["parameters/Idle/blend_position"] = facing_dir
		_animation_tree["parameters/Move/blend_position"] = facing_dir


func _buffer_slip_dir(input_dir: Vector2) -> Vector2:
	var new_input_dir: Vector2 = input_dir
	if input_dir.is_zero_approx():
		if not _slip_buffer_timer.is_stopped():
			new_input_dir = _buffered_input_dir
	else:
		_buffered_input_dir = input_dir
		_slip_buffer_timer.start(slip_buffer_time_sec)
	return new_input_dir


func _reset_slip_buffer() -> void:
	_buffered_input_dir = Vector2.ZERO
	_slip_buffer_timer.stop()


func _on_walking_time_set() -> void:
	if is_node_ready() and _debug_show_walking_time:
		_walking_time_label.text = "%.2f" % _walking_time


func _on_debug_show_walking_time_set() -> void:
	if is_node_ready():
		_walking_time_label.visible = _debug_show_walking_time
		_on_walking_time_set()


func _on_slip_buffer_timer_timeout() -> void:
	_buffered_input_dir = Vector2.ZERO
