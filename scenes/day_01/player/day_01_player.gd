@tool
extends Marker2D

signal ate
signal died

const TrunkPart: PackedScene = preload("res://scenes/day_01/player/trunk_part.tscn")

const INITIAL_DIR := Vector2i.RIGHT
const MAX_TRUNK_PARTS: int = 98
const DEBUG_POS := Vector2(120, 150)

@export var inverted_controls: bool
@export var pace_sec: float = 1.0:
	set(value):
		pace_sec = value
		_on_pace_sec_changed()

var stop_moving: bool:
	set(value):
		stop_moving = value
		_elapsed_time_sec = 0.0

var _curr_dir: Vector2i = INITIAL_DIR
var _next_dir: Vector2i = _curr_dir
var _elapsed_time_sec: float
var _growth_pending: bool
var _is_dead: bool:
	set(value):
		_is_dead = value
		if _is_dead:
			died.emit()

@onready var _is_ready: bool = true
@onready var _detector := $Head/Area2D as Area2D
@onready var _head := $Head as AnimatedSprite2D
@onready var _trunk := $Trunk
@onready var _first_trunk_part := $Trunk/TrunkPart000 as Node2D
@onready var _tail := $Tail as AnimatedSprite2D
@onready var _dead_head := $DeadHead
@onready var _pixels_per_step: int = int(_trunk.get_child(0).get_rect().size.x)


func _ready() -> void:
	_on_pace_sec_changed()
	_reset_body()


func _process(delta: float) -> void:
	if _is_dead or stop_moving or Engine.is_editor_hint():
		return
	
	_update_next_direction()
	
	_elapsed_time_sec += delta
	if _elapsed_time_sec >= pace_sec:
		_elapsed_time_sec = 0.0
		_move()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("fire") and not _is_dead:
		_growth_pending = true
	elif event.is_action_pressed("debug_revive") and _is_dead:
		revive()


func revive() -> void:
	if not _is_dead:
		return
	_reset()


func _is_root_parent() -> bool:
	return get_parent() == $/root


func _reset_body() -> void:
	for trunk_part in _trunk.get_children():
		if trunk_part != _first_trunk_part:
			trunk_part.queue_free()
	_head.global_position = DEBUG_POS if _is_root_parent() else global_position
	_head.rotation = Vector2(_curr_dir).angle()
	_first_trunk_part.position.x = _head.position.x - _pixels_per_step
	_first_trunk_part.position.y = _head.position.y
	_first_trunk_part.rotation = _head.rotation
	_tail.position.x = _first_trunk_part.position.x - _pixels_per_step
	_tail.position.y = _first_trunk_part.position.y
	_tail.rotation = _head.rotation
	_dead_head.visible = false
	if Engine.is_editor_hint():
		_tail.stop()
		_head.stop()
	else:
		_tail.play("default")
		_head.play("default")


func _reset() -> void:
	_elapsed_time_sec = 0.0
	_curr_dir = INITIAL_DIR
	_next_dir = _curr_dir
	_growth_pending = false
	_is_dead = false
	_reset_body()


func _update_next_direction() -> void:
	var candidate: Vector2i = _next_dir
	if Input.is_action_pressed("move_right"):
		candidate = Vector2i.LEFT if inverted_controls else Vector2i.RIGHT
	elif Input.is_action_pressed("move_left"):
		candidate = Vector2i.RIGHT if inverted_controls else Vector2i.LEFT
	elif Input.is_action_pressed("move_down"):
		candidate = Vector2i.UP if inverted_controls else Vector2i.DOWN
	elif Input.is_action_pressed("move_up"):
		candidate = Vector2i.DOWN if inverted_controls else Vector2i.UP
	
	if candidate + _curr_dir == Vector2i.ZERO:
		_next_dir = _curr_dir
	else:
		_next_dir = candidate


func _move() -> void:
	_curr_dir = _next_dir
	
	var last_trunk_part = Utils.last_child(_trunk)
	
	var new_trunk_part
	if _growth_pending:
		new_trunk_part = TrunkPart.instantiate()
		_growth_pending = false
	
	if new_trunk_part:
		new_trunk_part.position = last_trunk_part.position
	else:
		_tail.position = last_trunk_part.position
	
	for i in range(_trunk.get_child_count() - 1, 0, -1):
		var trunk_part = _trunk.get_child(i)
		var front_trunk_part = _trunk.get_child(i - 1)
		trunk_part.position = front_trunk_part.position
		trunk_part.rotation = front_trunk_part.rotation
	
	_first_trunk_part.position = _head.position
	_first_trunk_part.rotation = _head.rotation
	
	if new_trunk_part:
		_trunk.add_child(new_trunk_part)
		new_trunk_part.rotation = last_trunk_part.rotation
	else:
		_tail.rotation = last_trunk_part.rotation
		
	_head.rotation = Vector2(_curr_dir).angle()
	_head.position += Vector2(_curr_dir * _pixels_per_step)


func _die() -> void:
	_is_dead = true


func _on_pace_sec_changed() -> void:
	if not _is_ready or Engine.is_editor_hint():
		return
	
	var animation_speed = 0 if is_zero_approx(pace_sec) else int(1 / pace_sec)
	_head.sprite_frames.set_animation_speed("default", animation_speed)
	_tail.sprite_frames.set_animation_speed("default", animation_speed)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if _is_dead or Engine.is_editor_hint():
		return
	if area.collision_layer == 2:
		_die()


func _on_died() -> void:
	_dead_head.visible = true
	_dead_head.position = _first_trunk_part.position
	_dead_head.rotation = _head.rotation
	_tail.stop()
	_head.stop()