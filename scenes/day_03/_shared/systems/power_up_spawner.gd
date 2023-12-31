extends Node2D


enum State { DISABLED, READY, ENQUEUED, INSTANCED }

@export var player_data: Resource
@export var PowerUpItem: PackedScene
@export var cooldown: float = Utils.FRAME_TIME
@export var random: bool = true

var _state: int = State.DISABLED
var _world: Node2D

@onready var _screen_size: Vector2 = get_viewport_rect().size
@onready var _timer := $Cooldown as Timer


func enable(world: Node2D) -> void:
	if _state != State.DISABLED:
		disable()
	
	if not world:
		return
	
	_world = world

	_state = State.READY
	_enqueue_spawn()


func disable() -> void:
	_state = State.DISABLED
	_world = null
	_timer.stop()


func _enqueue_spawn() -> void:
	if _state == State.READY:
		_state = State.ENQUEUED
		_timer.start(cooldown)


func _try_spawn() -> void:
	if _state != State.ENQUEUED:
		return
	
	if player_data.power_up_count < player_data.MAX_POWER_UP:
		if not random:
			_spawn_power_up_item()
		elif randi() % 75 == 0:
			_spawn_power_up_item()
		else:
			_state = State.READY
			_enqueue_spawn()
	else:
		_state = State.READY
		_enqueue_spawn();


func _spawn_power_up_item() -> void:
	if _state != State.ENQUEUED:
		return
	
	var item = PowerUpItem.instantiate()
	var initial_pos := Vector2(randi() % int(_screen_size.x - 30) + 10, 3)
	item.global_position = initial_pos
	item.consumed_or_exited_screen.connect(_on_item_consumed_or_exited_screen)
	_world.add_child(item)
	_state = State.INSTANCED


func _on_item_consumed_or_exited_screen() -> void:
	if _state == State.INSTANCED:
		_state = State.READY
		_enqueue_spawn()


func _on_Cooldown_timeout() -> void:
	if _state == State.ENQUEUED:
		_try_spawn()


func _on_cooldown_timeout() -> void:
	if _state == State.ENQUEUED:
		_try_spawn()
