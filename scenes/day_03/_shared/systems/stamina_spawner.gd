extends Node2D


@export var player_data: Resource
@export var StaminaItem: PackedScene
@export var cooldown: float = Utils.FRAME_TIME
@export var random: bool = true

@onready var _screen_size: Vector2 = get_viewport_rect().size
@onready var _timer := $Cooldown as Timer

enum SpawnerState { DISABLED, READY, ENQUEUED, INSTANCED }

var _state: SpawnerState = SpawnerState.DISABLED
var _world: Node2D


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
	
	var stamina_item = StaminaItem.instantiate()
	var initial_pos := Vector2(randi() % int(_screen_size.x - 20) + 10, 3)
	stamina_item.global_position = initial_pos
	stamina_item.tree_exited.connect(_on_Item_tree_exited)
	_world.add_child(stamina_item)
	_state = SpawnerState.INSTANCED


func _on_Item_tree_exited() -> void:
	if _state == SpawnerState.INSTANCED:
		_state = SpawnerState.READY
		_enqueue_spawn()


func _on_Cooldown_timeout() -> void:
	if _state == SpawnerState.ENQUEUED:
		_try_spawn()
