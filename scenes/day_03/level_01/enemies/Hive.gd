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

var _horizontal_direction: float = 1
var _hive_drones: Array[HiveDrone]

@onready var body := $Body
@onready var movement_timer := $MovementTimer as Timer
@onready var gun_timer := $GunTimer as Timer
@onready var bottom_right_marker: Node2D = $Body/BottomRight
@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var viewport_width: float = viewport_size.x
@onready var viewport_height: float = viewport_size.y
@onready var min_pos_x: float = 0.0
@onready var max_pos_x: float = viewport_width - 6 * 16


func _ready() -> void:
	for child in body.get_children():
		if not child.is_in_group("enemies"):
			continue
		var drone = child as HiveDrone
		_hive_drones.append(drone)
		drone.dead.connect(_on_drone_dead)
	
	if auto_start: start()


func start() -> void:
	_update_curr_phase()
	gun_timer.start(TIME_BETWEEN_SHOTS_PHASE_DEFAULT)


func _count_enemies_left() -> int:
	return Utils.count(_hive_drones, func(item: HiveDrone): return not item.is_dead)


func _move() -> void:
	if position.x > max_pos_x or position.x < min_pos_x:
		_horizontal_direction *= -1
		if bottom_right_marker.global_position.y < viewport_height / 2:
			position.y += MOVE_DISTANCE_Y
	position.x += _horizontal_direction * MOVE_DISTANCE_X


func _update_curr_phase() -> void:
	var enemies_left = _count_enemies_left()
	if enemies_left == 1:
		print("phase_3")
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_3)
		return
	elif enemies_left <= 0:
		movement_timer.stop()
		return
	
	if bottom_right_marker.global_position.y < viewport_height / 6:
		print("phase_1")
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_1)
	else:
		print("phase_2")
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_2)


func _start_gun_cooldown(duration: float) -> void:
	gun_timer.start(duration)


func _on_gun_timer_timeout() -> void:
	var enemies_left = _count_enemies_left()
	print("enemies_left: %s" % enemies_left)
	
	if enemies_left < 0:
		gun_timer.stop()
		return
	
	if enemies_left == 1:
		var drone = Utils.first_or_null(
			_hive_drones, 
			func(i: Node): return not i.is_dead
		) as HiveDrone
		if drone and not drone.is_dead:
			drone.shoot()
			_start_gun_cooldown(TIME_BETWEEN_SHOTS_PHASE_DEFAULT)
		else:
			gun_timer.stop()
		return
	
	var drone := Utils.rand_item(_hive_drones)
	if not drone.is_dead:
		drone.shoot()
		var duration: float = 0.0
		if enemies_left > 1:
			duration = TIME_BETWEEN_SHOTS_PHASE_DEFAULT
		else:
			duration = TIME_BETWEEN_SHOTS_PHASE_3
		_start_gun_cooldown(duration)
	else:
		_start_gun_cooldown(Utils.FRAME_TIME)


func _on_movement_timer_timeout() -> void:
	_move()
	_update_curr_phase()
	#print("position: %s" % position)


func _on_drone_dead(_killer) -> void:
	_update_curr_phase()
	if _count_enemies_left() <= 0:
		dead.emit()
		queue_free()


func _kill_all_but_one() -> void:
	for i in _hive_drones.size() - 1:
		_hive_drones[i].kill(null)
		await get_tree().create_timer(2.4, false).timeout


func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug_kill"):
		_kill_all_but_one()
		get_viewport().set_input_as_handled()
