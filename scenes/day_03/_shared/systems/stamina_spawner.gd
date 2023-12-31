extends Node2D


enum SpawnerState { DISABLED, READY, ENQUEUED, INSTANCED }

@export var player_data: Resource
@export var StaminaItem: PackedScene
@export var cooldown: float = Utils.FRAME_TIME
@export var random: bool = true

var _state: SpawnerState = SpawnerState.DISABLED
var _world: Node2D

@onready var _screen_size: Vector2 = get_viewport_rect().size
@onready var _timer := $Cooldown as Timer


func enable(world: Node2D) -> void:
	if _state != SpawnerState.DISABLED:
		disable()
	
	if not world:
		return
	
	_world = world
	
	_state = SpawnerState.READY
	_enqueue_spawn()


func disable() -> void:
	_state = SpawnerState.DISABLED
	_world = null
	_timer.stop()


func _enqueue_spawn() -> void:
	if _state == SpawnerState.READY:
		_state = SpawnerState.ENQUEUED
		_timer.start(cooldown)


func _try_spawn() -> void:
	if _state != SpawnerState.ENQUEUED:
		return
	
	if not random:
		_spawn_new_stamina_item()
	elif player_data.stamina > player_data.MAX_STAMINA * 0.3:
		if randi() % 50 == 0:
			_spawn_new_stamina_item()
		else:
			_state = SpawnerState.READY
			_enqueue_spawn()
	else:
		_spawn_new_stamina_item()


func _spawn_new_stamina_item() -> void:
	if _state != SpawnerState.ENQUEUED:
		return
	
	var item = StaminaItem.instantiate()
	var initial_pos := Vector2(randi() % int(_screen_size.x - 20) + 10, 3)
	item.global_position = initial_pos
	item.consumed_or_exited_screen.connect(_on_item_consumed_or_exited_screen)
	_world.add_child(item)
	_state = SpawnerState.INSTANCED


func _on_item_consumed_or_exited_screen() -> void:
	if _state == SpawnerState.INSTANCED:
		_state = SpawnerState.READY
		_enqueue_spawn()


func _on_cooldown_timeout() -> void:
	if _state == SpawnerState.ENQUEUED:
		_try_spawn()
