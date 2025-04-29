@tool
extends CharacterBody2D


enum Direction {
	DOWN,
	LEFT,
	UP,
	RIGHT
}

const BloodSplatScene = preload("res://scenes/day_ex/objects/blood_splat.tscn")

const NORMAL_ANIM_SPEED_SCALE: float = 1.0
const SCARED_ANIM_SPEED_SCALE: float = 10.0
const DIRECTION_VECTORS: Dictionary[Direction, Vector2] = {
	Direction.DOWN: Vector2.DOWN,
	Direction.LEFT: Vector2.LEFT,
	Direction.UP: Vector2.UP,
	Direction.RIGHT: Vector2.RIGHT,
}
const VECTOR_ANIMS: Dictionary[Vector2, StringName] = {
	Vector2.DOWN: &"move_down",
	Vector2.LEFT: &"move_left",
	Vector2.UP: &"move_up",
	Vector2.RIGHT: &"move_right",
}

@export var _sprite_sheet: Texture2D:
	set(value):
		_sprite_sheet = value
		_on_sprite_sheet_set()
@export var _initial_facing_dir: Direction:
	set(value):
		_initial_facing_dir = value
		_on_initial_facing_dir_set()
@export_group("Panic Animation", "_panic")
@export var _panic_speed: float = 100
@export var _panic_sound: AudioStream
@export_range(0.1, 1.0) var _panic_scream_delay_sec: float = 0.5

var _speed: float
var _direction: Vector2
var _scream_tween: Tween

@onready var _timer: Timer = $Timer
@onready var _sprite_2d: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_on_sprite_sheet_set()
	_on_initial_facing_dir_set()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or \
			# This conditions mitigate the whole "CharacterBody2Ds pushing each 
			# other" problem.
			# Since this NPC is only moved for a brief cutscene at the end,
			# this workaround is good enough when the player's physics process 
			# is disabled while the cutscene is playing.
			#
			# See more: https://github.com/godotengine/godot/issues/34345
			is_zero_approx(_speed) or \
			_direction.is_zero_approx():
		return
	
	if move_and_collide(_speed * _direction * delta):
		_change_to_random_move_dir()


func get_scared(is_scared: bool) -> void:
	if is_scared:
		_start_screaming()
		_animation_player.speed_scale = SCARED_ANIM_SPEED_SCALE
		_speed = _panic_speed
		_start_panic_move_timer()
	else:
		_stop_screaming()
		_animation_player.speed_scale = NORMAL_ANIM_SPEED_SCALE
		_speed = 0.0
		_timer.stop()


func die() -> void:
	_stop_screaming()
	var parent := get_parent() as Node2D
	if parent:
		var blood_splat := BloodSplatScene.instantiate()
		blood_splat.global_position = global_position
		parent.add_child(blood_splat)
	queue_free()


func _change_direction(new_direction: Vector2) -> void:
	if new_direction in DIRECTION_VECTORS.values():
		var new_anim: String = _animation_player.current_animation
		if new_direction != _direction:
			new_anim = VECTOR_ANIMS[new_direction]
		if new_anim != _animation_player.current_animation:
			_animation_player.play(new_anim)
			if Engine.is_editor_hint():
				_animation_player.stop()
		_direction = new_direction


func _change_to_random_move_dir() -> void:
	var allowed_dirs_count: int = DIRECTION_VECTORS.size()
	var idx: int = randi_range(0, allowed_dirs_count - 1)
	var dir: Vector2 = DIRECTION_VECTORS[idx]
	if dir == _direction:
		idx = wrapi(idx + 1, 0, allowed_dirs_count)
		dir = DIRECTION_VECTORS[idx]
	_change_direction(dir)


func _start_panic_move_timer() -> void:
	var duration: float = randf_range(0.1, 0.4)
	_timer.start(duration)


func _scream() -> void:
	SoundManager.play_sound(_panic_sound)


func _stop_screaming() -> void:
	if _scream_tween:
		_scream_tween.kill()
	_scream_tween = null


func _start_screaming() -> void:
	_stop_screaming()
	_scream_tween = create_tween()
	_scream_tween.set_loops()
	_scream_tween.tween_callback(_scream).set_delay(_panic_scream_delay_sec)


func _on_sprite_sheet_set() -> void:
	if is_node_ready():
		_sprite_2d.texture = _sprite_sheet


func _on_initial_facing_dir_set() -> void:
	if not is_node_ready():
		return
	
	var dir: Vector2 = DIRECTION_VECTORS.get(_initial_facing_dir, Vector2.DOWN)
	_change_direction(dir)


func _on_timer_timeout() -> void:
	_change_to_random_move_dir()
	_start_panic_move_timer()
