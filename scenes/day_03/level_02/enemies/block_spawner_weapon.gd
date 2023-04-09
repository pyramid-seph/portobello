extends Node2D


@export var target: Node2D
@export var _cooldown: float = 1.0
@export var is_active: bool:
	set(value):
		is_active = value
		_on_set_is_active()
@export var Block: PackedScene

@onready var _timer := $Timer as Timer
@onready var _is_ready: bool = true


func _ready() -> void:
	_on_set_is_active()


func _activate() -> void:
	_timer.start(_cooldown)


func _deactivate() -> void:
	_timer.stop()


func _on_set_is_active() -> void:
	if not _is_ready:
		return
	
	if is_active:
		_activate()
	else:
		_deactivate()


func _on_timer_timeout() -> void:
	if target:
		var block = Block.instantiate() as MovingDay03Enemy
		add_child(block) # TODO What is world?
		block.movement_pattern = SimpleMover.Pattern.VERTICAL_DOWN
		block.global_position.x = target.global_position.x
		block.global_position.y = global_position.y
		block.z_index = 0 # TODO motership index no likey:(
	else:
		print("No target set. Will retry next timeout.")
	_timer.start(_cooldown)
