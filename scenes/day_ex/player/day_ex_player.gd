extends CharacterBody2D


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

var _walking_time: float:
	set(value):
		_walking_time = value
		_on_walking_time_set()

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _walking_time_label: Label = $WalkingTimeLabel


func _ready() -> void:
	_on_walking_time_set()
	_on_debug_show_walking_time_set()


func _physics_process(delta: float) -> void:
	var direction: Vector2 = _get_input()
	velocity = speed * direction
	
	move_and_slide()
	_update_animation(direction)
	
	# TODO this still counts time when the player retries moving after colliding whit a direction while on wall. This also affects animation!
	if not get_real_velocity().is_zero_approx() and not velocity.is_zero_approx():
		_walking_time += delta
	
	if _debug_show_move_vectors:
		queue_redraw()
	
	#if not get_real_velocity().is_zero_approx() and is_on_wall():
		#print("DIR: %s - REAL_VEL: %s - VEL: %s" % [direction, get_real_velocity(), velocity])

func _draw() -> void:
	if is_on_wall():
		var wall_normal: Vector2 = get_wall_normal()
		draw_line(Vector2.ZERO, wall_normal * 15.0, Color.GREEN, 4.0)
	draw_line(Vector2.ZERO, get_real_velocity().normalized() * 15.0, Color.RED, 2.0)


func reset_walking_time() -> void:
	_walking_time = 0.0


func get_walking_time() -> float:
	return _walking_time


func _get_input() -> Vector2:
	var input: Vector2
	if Input.is_action_pressed("move_up"):
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
