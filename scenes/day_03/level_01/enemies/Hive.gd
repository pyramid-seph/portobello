extends Node2D


signal died
signal almost_dead

const TIME_BETWEEN_MOVEMENT_PHASE_1: float = 1.6
const TIME_BETWEEN_MOVEMENT_PHASE_2: float = 0.8
const TIME_BETWEEN_MOVEMENT_PHASE_3: float = 0.4
const TIME_BETWEEN_MOVEMENT_PHASE_4: float = Utils.FRAME_TIME
const GUNS_COOLDOWN: float = 0.4
const SPRITE_WIDTH: float = 16.0

var world:
	set(value):
		world = value
		if not _is_ready: return
		for drone: HiveDrone in Utils.children_in_group(body, "hive_drones"):
			drone.world = value

var _horizontal_direction: float = 1
var _hive_drones: Array[HiveDrone] = []

@onready var _is_ready = true
@onready var body := $Body
@onready var movement_timer := $MovementTimer as Timer
@onready var gun_timer := $GunTimer as Timer
@onready var bottom_right_marker: Node2D = $Body/BottomRight
@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var viewport_width: float = viewport_size.x
@onready var viewport_height: float = viewport_size.y
@onready var min_pos_x: float = SPRITE_WIDTH
@onready var max_pos_x: float = viewport_width - SPRITE_WIDTH
@onready var move_distance_x: float = floorf(viewport_width / 20)
@onready var move_distance_y: float = floorf((viewport_height / 2) / 20)


func _ready() -> void:
	for drone: HiveDrone in Utils.children_in_group(body, "hive_drones"):
		drone.world = world
		_hive_drones.append(drone)
		drone.died.connect(_on_drone_dead)


func start() -> void:
	_update_curr_phase()
	_start_gun_cooldown(GUNS_COOLDOWN)


func body_height() -> float:
	return SPRITE_WIDTH * 3


func _move() -> void:
	if bottom_right_marker.global_position.x > max_pos_x or position.x < min_pos_x:
		_horizontal_direction *= -1
		if bottom_right_marker.global_position.y < viewport_height / 2:
			position.y += move_distance_y
	position.x += _horizontal_direction * move_distance_x


func _update_curr_phase() -> void:
	var drones = _get_drones_left()
	if drones.is_empty():
		return
	if drones.size() == 1:
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_4)
		return
	
	if bottom_right_marker.global_position.y < floorf(viewport_height / 6):
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_1)
	elif bottom_right_marker.global_position.y < floorf(viewport_height / 4):
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_2)
	else:
		movement_timer.start(TIME_BETWEEN_MOVEMENT_PHASE_3)

func _start_gun_cooldown(duration: float) -> void:
	gun_timer.start(duration)


func _get_drones_left() -> Array[HiveDrone]:
	return _hive_drones.filter(func(drone: HiveDrone): return not drone.is_dead())


func _on_gun_timer_timeout() -> void:
	var drones = _get_drones_left()
	if drones.is_empty():
		return
	
	var drone: HiveDrone = Utils.rand_item(drones)
	if drone and not drone.is_dead():
		drone.shoot()
		_start_gun_cooldown(GUNS_COOLDOWN)
	else:
		_start_gun_cooldown(Utils.FRAME_TIME)


func _on_drone_dead() -> void:
	var drones = _get_drones_left()
	var enemies_left = drones.size()
	if enemies_left > 1:
		return
	if enemies_left == 1:
		drones[0].is_immune_to_bullets = true
		almost_dead.emit()
	else:
		died.emit()
		queue_free()


func _on_movement_timer_timeout() -> void:
	_move()
	_update_curr_phase()
