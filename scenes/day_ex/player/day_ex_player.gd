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


func _ready() -> void:
	_interact_sprite_2d.hide()
	_on_walking_time_set()
	_on_debug_show_walking_time_set()


func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = _get_input()
	var is_on_slippery_floor: bool = _slippery_floor_detector.is_on_slippery_floor()
	if is_on_slippery_floor:
		_set_slip_velocity(input_dir)
	else:
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
	_interact_sprite_2d.visible = \
			_action_area_detector.is_action_area_detected() and \
			is_processing_unhandled_input()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		get_viewport().set_input_as_handled()
		_action_area_detector.execute_detected_action_area(self)


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
	var input: Vector2
	if not is_processing_unhandled_input():
		input = Vector2.ZERO
	elif Input.is_action_pressed("move_up"):
		input = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		input = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		input = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		input = Vector2.RIGHT
	else:
		input = Vector2.ZERO
	return input


func _update_animation_params(facing_dir: Vector2, is_idle: bool):
	_is_iddle = is_idle
	if facing_dir != Vector2.ZERO:
		_animation_tree["parameters/Idle/blend_position"] = facing_dir
		_animation_tree["parameters/Move/blend_position"] = facing_dir


func _on_walking_time_set() -> void:
	if is_node_ready() and _debug_show_walking_time:
		_walking_time_label.text = "%.2f" % _walking_time


func _on_debug_show_walking_time_set() -> void:
	if is_node_ready():
		_walking_time_label.visible = _debug_show_walking_time
		_on_walking_time_set()
