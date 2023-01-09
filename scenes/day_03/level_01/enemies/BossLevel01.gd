extends Node2D


signal dead


const MOVE_DISTANCE_X: float = 12.0
const MOVE_DISTANCE_Y: float = 8.0
const TIME_BETWEEN_MOVEMENT_PHASE_1: float = 1.6
const TIME_BETWEEN_MOVEMENT_PHASE_2: float = 0.8
const TIME_BETWEEN_MOVEMENT_PHASE_3: float = 0.3
const TIME_BETWEEN_SHOTS_PHASE_DEFAULT: float = 0.8
const TIME_BETWEEN_SHOTS_PHASE_3: float = 0.4

@export var auto_start: bool = false

var _enemies_left: int = 0
var _horizontal_direction: float = 1

@onready var movement_timer := $MovementTimer as Timer
@onready var gun_timer := $GunTimer as Timer
@onready var bottom_right_marker: Node2D = $Hive/BottomRight
@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var viewport_width: float = viewport_size.x
@onready var viewport_height: float = viewport_size.y
@onready var min_pos_x: float = 0.0
@onready var max_pos_x: float = viewport_width - 6 * 16
@onready var hive = $Hive


func _ready() -> void:
	for child in hive.get_children():
		if not child.is_in_group("enemies"):
			continue
		_enemies_left += 1
		var drone = child as HiveDrone
		drone.dead.connect(func(_killer):
			_enemies_left -= 1
			print("_enemies_left: %s" % _enemies_left)
			_update_curr_phase()
			if _enemies_left <= 0:
				dead.emit()
				queue_free()
		)
	
	if auto_start: start()


func start() -> void:
	_update_curr_phase()
	gun_timer.start(TIME_BETWEEN_SHOTS_PHASE_DEFAULT)


func _move() -> void:
	if position.x > max_pos_x or position.x < min_pos_x:
		_horizontal_direction *= -1
		if bottom_right_marker.global_position.y < viewport_height / 2:
			position.y += MOVE_DISTANCE_Y
	position.x += _horizontal_direction * MOVE_DISTANCE_X


func _update_curr_phase() -> void:
	if _enemies_left == 1:
		print("phase_3")
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_3)
		return
	elif _enemies_left < 0:
		movement_timer.stop()
		return
	print("bottom_right_marker.global_position.y: %s" % bottom_right_marker.global_position.y )
	if bottom_right_marker.global_position.y < viewport_height / 6:
		print("phase_1")
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_1)
	else:
		print("phase_2")
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_2)


func _start_gun_cooldown(duration: float) -> void:
	gun_timer.start(duration)


func _on_gun_timer_timeout() -> void:
	var drone = Utils.rand_child_in_group(hive, "enemies")
	if drone and not drone.is_queued_for_deletion():
		drone.shoot()
		var duration: float = 0.0
		if _enemies_left > 1:
			duration = TIME_BETWEEN_SHOTS_PHASE_DEFAULT
		else:
			duration = TIME_BETWEEN_SHOTS_PHASE_3
		_start_gun_cooldown(duration)
	else:
		_start_gun_cooldown(Utils.FRAME_TIME)


func _on_movement_timer_timeout() -> void:
	_move()
	_update_curr_phase()
	print("position: %s" % position)


func _kill_all_but_one() -> void:
	var item = Utils.childre_in_group(hive, "enemies")
	for i in item.size() - 1:
		item[i].kill(null)


func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug_kill"):
		_kill_all_but_one()
		get_viewport().set_input_as_handled()
