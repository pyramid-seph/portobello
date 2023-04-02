extends Node2D


@export var player_data: Resource
@export var PowerUpItem: PackedScene
@export var cooldown: float = Utils.FRAME_TIME
@export var random: bool = true

@onready var _screen_size: Vector2 = get_viewport_rect().size
@onready var _timer := $Cooldown as Timer

enum State { DISABLED, READY, ENQUEUED, INSTANCED }

var _state: int = State.DISABLED
var _world: Node2D


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
	
	var power_up_item = PowerUpItem.instantiate()
	var initial_pos := Vector2(randi() % int(_screen_size.x - 30) + 10, 3)
	power_up_item.global_position = initial_pos
	power_up_item.tree_exited.connect(_on_Item_tree_exited)
	_world.add_child(power_up_item)
	_state = State.INSTANCED


func _on_Item_tree_exited() -> void:
	if _state == State.INSTANCED:
		_state = State.READY
		_enqueue_spawn()


func _on_Cooldown_timeout() -> void:
	if _state == State.ENQUEUED:
		_try_spawn()
