extends Node2D


export(Resource) var player_data: Resource
export(PackedScene) var power_up_item
export var cooldown : float = 0.08

onready var screen_size = get_viewport_rect().size
onready var timer = $Cooldown

var _state = State.DISABLED
var _world

enum State { DISABLED, READY, ENQUEUED, INSTANCED }


func enable(world):
	if _state != State.DISABLED:
		disable()
	
	if not world:
		return
	
	_world = world

	_state = State.READY
	_enqueue_spawn()


func disable():
	_state = State.DISABLED
	timer.stop()


func _enqueue_spawn():
	if _state == State.READY:
		_state = State.ENQUEUED
		timer.start(cooldown)


func _try_spawn():
	if _state != State.ENQUEUED:
		return
	
	if player_data.power_up_count < player_data.MAX_POWER_UP:
		if randi() % 75 == 0:
			_instance_new_power_up_item()
		else:
			_state = State.READY
			_enqueue_spawn()
	else:
		_state = State.READY
		_enqueue_spawn();


func _instance_new_power_up_item():
	if _state != State.ENQUEUED:
		return
	
	var new_power_up_item = power_up_item.instance()
	var initial_pos = Vector2(randi() % int(screen_size.x - 30) + 10, 3)
	new_power_up_item.global_position = initial_pos
	new_power_up_item.connect("tree_exited", self, "_on_Item_tree_exited")
	_world.add_child(new_power_up_item)
	_state = State.INSTANCED


func _on_Item_tree_exited():
	if _state == State.INSTANCED:
		_state = State.READY
		_enqueue_spawn()


func _on_Cooldown_timeout():
	if _state == State.ENQUEUED:
		_try_spawn()
