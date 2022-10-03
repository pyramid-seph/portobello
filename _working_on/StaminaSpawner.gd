extends Node2D


@export var player_data: Resource
@export var stamina_item: PackedScene
@export var cooldown: float = Utils.FRAME_TIME

@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var timer: Timer = $Cooldown

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
	timer.stop()


func _enqueue_spawn() -> void:
	if _state == State.READY:
		_state = State.ENQUEUED
		timer.start(cooldown)


func _try_spawn() -> void:
	if _state != State.ENQUEUED:
		return
	
	if player_data.stamina > player_data.MAX_STAMINA * 0.3:
		if randi() % 50 == 0:
			_instance_new_stamina_item()
		else:
			_state = State.READY
			_enqueue_spawn()
	else:
		_instance_new_stamina_item()


func _instance_new_stamina_item() -> void:
	if _state != State.ENQUEUED:
		return
	
	var new_stamina_item = stamina_item.instantiate()
	var initial_pos := Vector2(randi() % int(screen_size.x - 20) + 10, 3)
	new_stamina_item.global_position = initial_pos
	new_stamina_item.tree_exited.connect(_on_Item_tree_exited)
	_world.add_child(new_stamina_item)
	_state = State.INSTANCED


func _on_Item_tree_exited() -> void:
	if _state == State.INSTANCED:
		_state = State.READY
		_enqueue_spawn()


func _on_Cooldown_timeout() -> void:
	if _state == State.ENQUEUED:
		_try_spawn()
