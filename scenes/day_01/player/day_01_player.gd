extends Marker2D

signal ate
signal died(death_cause: DeathCause)
signal stamina_changed(remaining_stamina: float)

enum DeathCause {
	FATIGUE,
	CRASH,
}

const TrunkPart: PackedScene = preload("res://scenes/day_01/player/trunk_part.tscn")

const INITIAL_DIR := Vector2i.RIGHT
const MAX_TRUNK_PARTS: int = 98
const DEBUG_POS := Vector2(120, 150)

@export var stamina_sec: float:
	set(value):
		stamina_sec = value
		_remaining_stamina = stamina_sec
@export var inverted_controls: bool
@export var pace_sec: float = 1.0

var is_allowed_to_move := true

var _curr_frame: int
var _curr_dir: Vector2i = INITIAL_DIR
var _next_dir: Vector2i = _curr_dir
var _elapsed_time_sec: float
var _growth_pending: bool
var _is_dead: bool
var _is_awaiting_first_movement := true
var _remaining_stamina: float:
	set(value):
		_remaining_stamina = value
		if _can_get_tired():
			stamina_changed.emit(_remaining_stamina)

@onready var _head := $Head as AnimatedSprite2D
@onready var _trunk := $Trunk
@onready var _first_trunk_part := $Trunk/TrunkPart000 as Node2D
@onready var _tail := $Tail as AnimatedSprite2D
@onready var _dead_head := $DeadHead
@onready var _pixels_per_step := int(_first_trunk_part.get_rect().size.x)


func _ready() -> void:
	_reset()


func _physics_process(delta: float) -> void:
	_elapsed_time_sec += delta
	var tick: bool = _elapsed_time_sec >= pace_sec
	if tick:
		_elapsed_time_sec = 0.0
	
	if tick and not _is_dead:
		_animate()
	
	if _is_dead or not is_allowed_to_move:
		return
	
	if _update_stamina(delta):
		return
	
	var is_first_movement_done := _update_next_direction()
	
	if tick or is_first_movement_done:
		_move()
		_elapsed_time_sec = 0.0
	
	if is_first_movement_done:
		_animate()


func revive(force: bool = false) -> void:
	if _is_dead or force:
		_reset()


func get_global_start_position() -> Vector2:
	return global_position


func get_head_global_postion() -> Vector2:
	return _head.global_position


func get_first_trunk_part_global_postion() -> Vector2:
	return _first_trunk_part.global_position


func get_tail_global_postion() -> Vector2:
	return _tail.global_position


func _animate() -> void:
	_curr_frame += 1
	var anim_frame = _curr_frame % 2
	_head.frame = anim_frame
	_tail.frame = anim_frame


func _can_get_tired() -> bool:
	return stamina_sec > 0.0


func _update_stamina(delta: float) -> bool:
	if _can_get_tired() and not _is_awaiting_first_movement:
		_remaining_stamina -= delta
		if _remaining_stamina <= 0:
			_die(DeathCause.FATIGUE)
			return true
	return false


func _is_root_parent() -> bool:
	return get_parent() == $/root


func _reset_body() -> void:
	for trunk_part: Node2D in _trunk.get_children():
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
	_head.visible = true
	_dead_head.visible = false
	_first_trunk_part.visible = true


func _reset() -> void:
	_is_awaiting_first_movement = true
	_elapsed_time_sec = 0.0
	_curr_dir = INITIAL_DIR
	_next_dir = _curr_dir
	_growth_pending = false
	_is_dead = false
	_remaining_stamina = stamina_sec
	_curr_frame = 0
	_head.frame = 0
	_tail.frame = 0
	_reset_body()


func _update_next_direction() -> bool:
	var pressed := Vector2i.ZERO
	if Input.is_action_pressed("move_right"):
		pressed += Vector2i.LEFT if inverted_controls else Vector2i.RIGHT
	if Input.is_action_pressed("move_left"):
		pressed += Vector2i.RIGHT if inverted_controls else Vector2i.LEFT
	if Input.is_action_pressed("move_down"):
		pressed += Vector2i.UP if inverted_controls else Vector2i.DOWN
	if Input.is_action_pressed("move_up"):
		pressed += Vector2i.DOWN if inverted_controls else Vector2i.UP
	
	var direction_changed: bool = false
	if pressed.x != 0 and pressed.x + _curr_dir.x != 0 and pressed.x != _curr_dir.x:
		_next_dir = Vector2i(pressed.x, 0)
		direction_changed = true
	elif pressed.y != 0 and pressed.y + _curr_dir.y != 0 and pressed.y != _curr_dir.y:
		_next_dir = Vector2i(0, pressed.y)
		direction_changed = true
	
	var old_is_awaiting_first_movement_val := _is_awaiting_first_movement
	if _is_awaiting_first_movement:
		_is_awaiting_first_movement = !(direction_changed or pressed == INITIAL_DIR)
	return old_is_awaiting_first_movement_val != _is_awaiting_first_movement


func _move() -> void:
	_curr_dir = _next_dir

	if _is_awaiting_first_movement:
		return

	var last_trunk_part = Utils.last_child(_trunk)
	
	var new_trunk_part: Node2D
	if _growth_pending:
		new_trunk_part = TrunkPart.instantiate()
		_growth_pending = false
	
	if new_trunk_part:
		new_trunk_part.position = last_trunk_part.position
		new_trunk_part.rotation = last_trunk_part.rotation
	else:
		_tail.position = last_trunk_part.position
	
	for i: int in range(_trunk.get_child_count() - 1, 0, -1):
		var trunk_part = _trunk.get_child(i)
		var front_trunk_part = _trunk.get_child(i - 1)
		trunk_part.position = front_trunk_part.position
		trunk_part.rotation = front_trunk_part.rotation
	
	_first_trunk_part.position = _head.position
	_first_trunk_part.rotation = _head.rotation
	
	if new_trunk_part:
		_trunk.add_child(new_trunk_part)
	else:
		_tail.rotation = last_trunk_part.rotation
	
	_head.rotation = Vector2(_curr_dir).angle()
	_head.position += Vector2(_curr_dir * _pixels_per_step)


func _eat(thing: Node) -> void:
	_growth_pending = _trunk.get_child_count() < MAX_TRUNK_PARTS
	thing.queue_free()
	ate.emit()


func _die(cause: DeathCause) -> void:
	if not _is_dead:
		_is_dead = true
		_on_died(cause)
		died.emit(cause)


func _on_died(cause: DeathCause) -> void:
	_dead_head.visible = true
	_head.visible = false
	
	var dead_head_pos
	if cause == DeathCause.CRASH:
		dead_head_pos = _first_trunk_part.position
		_first_trunk_part.visible = false
		Utils.vibrate_joy()
	else:
		dead_head_pos = _head.position
	_dead_head.position = dead_head_pos
	_dead_head.rotation = _head.rotation


func _on_area_2d_area_entered(area: Area2D) -> void:
	if _is_dead:
		return
	
	match area.collision_layer:
		Constants.LAYER_HITBOX:
			_die(DeathCause.CRASH)
		Constants.LAYER_PICKUP:
			_eat(area)


func _on_area_2d_body_entered(_body: Node2D) -> void:
	if not _is_dead:
		_die(DeathCause.CRASH)
