extends CharacterBody2D


enum FacingDirection {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

const ActionArea = preload("res://scenes/day_ex/game/speak_action_area.gd")
const ActionAreaDetector = preload("res://scenes/day_ex/player/action_area_detector.gd")

@export var speed: float = 33.33

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

var _facing_direction: Vector2 = Vector2.RIGHT
var _walking_time: float:
	set(value):
		_walking_time = value
		_on_walking_time_set()

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _walking_time_label: Label = $WalkingTimeLabel
@onready var _action_area_detector: ActionAreaDetector = $ActionAreaDetector
@onready var _interact_sprite_2d: Sprite2D = $InteractSprite2D


func _ready() -> void:
	_interact_sprite_2d.hide()
	_on_walking_time_set()
	_on_debug_show_walking_time_set()


func _physics_process(delta: float) -> void:
	var direction: Vector2 = _get_input()
	velocity = speed * direction
	
	move_and_slide()
	
	if direction != Vector2.ZERO:
		_facing_direction = direction
	_action_area_detector.rotation = _facing_direction.angle()
	
	_update_animation(direction)
	
	# TODO this still counts time when the player retries moving after colliding whit a direction while on wall. This also affects animation!
	if not get_real_velocity().is_zero_approx() and not velocity.is_zero_approx():
		_walking_time += delta
	
	if _debug_show_move_vectors:
		queue_redraw()
	
	#if not get_real_velocity().is_zero_approx() and is_on_wall():
		#print("DIR: %s - REAL_VEL: %s - VEL: %s" % [direction, get_real_velocity(), velocity])


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
	
	match facing_direction:
		FacingDirection.LEFT:
			_facing_direction = Vector2.LEFT
			_animated_sprite_2d.play("iddle_horizontal")
			_animated_sprite_2d.flip_h = true
			_animated_sprite_2d.flip_v = false
		FacingDirection.RIGHT:
			_facing_direction = Vector2.RIGHT
			_animated_sprite_2d.play("iddle_horizontal")
			_animated_sprite_2d.flip_h = false
			_animated_sprite_2d.flip_v = false
		FacingDirection.UP:
			_facing_direction = Vector2.UP
			_animated_sprite_2d.play("iddle_vertical")
			_animated_sprite_2d.flip_h = false
			_animated_sprite_2d.flip_v = false
		FacingDirection.DOWN:
			_facing_direction = Vector2.DOWN
			_animated_sprite_2d.play("iddle_vertical")
			_animated_sprite_2d.flip_h = false
			_animated_sprite_2d.flip_v = true


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


func _update_animation(direction: Vector2) -> void:
	var animation: String = _animated_sprite_2d.animation
	var flip_h: bool = _animated_sprite_2d.flip_h
	var flip_v: bool = _animated_sprite_2d.flip_v
	if direction == Vector2.ZERO or get_real_velocity().is_zero_approx():
		if not animation.begins_with("iddle_"):
			if animation == "move_horizontal":
				animation = "iddle_horizontal"
			else:
				animation = "iddle_vertical"
	else:
		flip_h = direction.x < 0
		flip_v = direction.y > 0
		if is_zero_approx(direction.x):
			animation = "move_vertical"
		else:
			animation = "move_horizontal"
	_animated_sprite_2d.play(animation)
	_animated_sprite_2d.flip_h = flip_h
	_animated_sprite_2d.flip_v = flip_v


func _on_walking_time_set() -> void:
	if is_node_ready() and _debug_show_walking_time:
		_walking_time_label.text = "%.2f" % _walking_time


func _on_debug_show_walking_time_set() -> void:
	if is_node_ready():
		_walking_time_label.visible = _debug_show_walking_time
		_on_walking_time_set()
