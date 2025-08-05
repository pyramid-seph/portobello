extends Node2D


@export var target: Node2D
@export var world: Node2D
@export var is_active: bool:
	set(value):
		var old_is_active = is_active
		is_active = value
		if old_is_active != is_active:
			_on_is_active_changed()
@export var is_max_speed_enabled: bool = false:
	set(value):
		var old_is_max_speed_enabled = is_max_speed_enabled
		is_max_speed_enabled = value
		if old_is_max_speed_enabled != is_max_speed_enabled:
			_on_is_max_speed_enabled_changed()

@export var _normal_cooldown: float = 1.0
@export var _sped_up_cooldown: float = 1.0
		
@export var Block: PackedScene

var _cooldown: float = 0.0

@onready var _timer := $Timer as Timer


func _ready() -> void:
	_on_is_active_changed()
	_on_is_max_speed_enabled_changed()


func _activate() -> void:
	_spawn_block.call_deferred()


func _deactivate() -> void:
	_timer.stop()


func _on_is_active_changed() -> void:
	if not is_node_ready():
		return
	
	if is_active:
		_activate()
	else:
		_deactivate()


func _on_is_max_speed_enabled_changed() -> void:
	if not is_node_ready():
		return
	
	if is_max_speed_enabled:
		_cooldown = _sped_up_cooldown
	else:
		_cooldown = _normal_cooldown


func _spawn_block() -> void:
	if target:
		var block := Block.instantiate() as MovingDay03Enemy
		block.world = world
		block.movement_pattern = SimpleMover.Pattern.VERTICAL_DOWN
		block.global_position.x = target.global_position.x
		block.global_position.y = global_position.y
		world.add_child(block)
	else:
		Log.d("No target set. Will retry next timeout.")
	_timer.start(_cooldown)


func _on_timer_timeout() -> void:
	_spawn_block()
