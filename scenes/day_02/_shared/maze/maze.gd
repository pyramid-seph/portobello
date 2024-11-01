extends TileMapLayer


signal completed
signal ghost_eaten
signal treat_eaten
signal super_treat_eaten
signal player_dying
signal player_died

enum MazeState {
	PREPARED,
	STARTED,
	FAILED,
	COMPLETED,
	QUITTED,
}

const Day02Enemy = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")
const Day02Player = preload("res://scenes/day_02/_shared/player/day_02_player.gd")
const MazeBgm = preload("res://scenes/day_02/_shared/maze/maze_bgm.gd")

const GHOST_RESPAWN_DELAY_SECONDS: float = 0.5
const RED_GHOST_MOVEMENT_DELAY_SECONDS: float = 0.5
const YELLOW_GHOST_MOVEMENT_DELAY_SECONDS: float = 1.0
const RESPAWN_RETRY_DELAY_SECONDS: float = 0.16

@export var blue_ghost_speed: float = 40.0:
	set(value):
		blue_ghost_speed = value
		_on_blue_ghost_speed_set()
@export var red_ghost_speed: float = 40.0:
	set(value):
		red_ghost_speed = value
		_on_red_ghost_speed_set()
@export var yellow_ghost_speed: float = 40.0:
	set(value):
		yellow_ghost_speed = value
		_on_yellow_ghost_speed_set()

var _state: MazeState

@onready var _player_init_pos_marker = $PlayerInitPosMarker as Marker2D
@onready var _respawn_pos_marker = $RespawnPosMarker as Marker2D
@onready var _player_out_of_maze: Marker2D = $PlayerOutOfMazeMarker
@onready var _player := $Day02Player as Day02Player
@onready var _food_node := $Food as Node
@onready var _blue_ghost := $BlueGhost as Day02Enemy
@onready var _red_ghost := $RedGhost as Day02Enemy
@onready var _yellow_ghost := $YellowGhost as Day02Enemy
@onready var _blue_ghost_respawn_timer := $BlueGhostRespawnTimer as Timer
@onready var _red_ghost_respawn_timer := $RedGhostRespawnTimer as Timer
@onready var _yellow_ghost_respawn_timer := $YellowGhostRespawnTimer as Timer
@onready var _red_ghost_first_spawn_timer := $RedGhostFirstSpawnTimer as Timer
@onready var _yellow_ghost_first_spawn_timer := $YellowGhostFirstSpawnTimer as Timer
@onready var _player_revival_delay_timer := $PlayerRevivalDelayTimer as Timer
@onready var _maze_bgm: MazeBgm = $MazeBgm


func _ready() -> void:
	_on_blue_ghost_speed_set()
	_on_red_ghost_speed_set()
	_on_yellow_ghost_speed_set()
	if get_parent() == $/root:
		prepare()
		start()


func quit() -> void:
	_state = MazeState.QUITTED
	visible = false
	_player.teleport(local_to_map(_player_out_of_maze.position))
	# Awaiting for a physics frame so the enemies can receive an area_exit signal.
	# This fixes a bug which makes the player invincible and unable to eat ghosts.
	await get_tree().physics_frame
	await get_tree().physics_frame
	process_mode = Node.PROCESS_MODE_DISABLED


func prepare() -> void:
	_maze_bgm.play()
	_stop_pending_player_revival()
	_stop_pending_ghost_respawn()
	_stop_pending_ghost_first_spawn()
	_reset_player()
	_reset_all_ghosts()
	_reset_food()
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	_state = MazeState.PREPARED


func start() -> void:
	if _state == MazeState.PREPARED:
		_player.is_movement_allowed = true
		_blue_ghost.is_halt = false
		_red_ghost_first_spawn_timer.start(RED_GHOST_MOVEMENT_DELAY_SECONDS)
		_yellow_ghost_first_spawn_timer.start(YELLOW_GHOST_MOVEMENT_DELAY_SECONDS)
		_state = MazeState.STARTED


func failed() -> void:
	if _state == MazeState.STARTED:
		_stop_pending_player_revival()
		_stop_pending_ghost_first_spawn()
		_stop_pending_ghost_respawn()
		_halt_all_ghosts()
		_halt_player()
		_maze_bgm.stop()
		_state = MazeState.FAILED


func revive_player() -> void:
	if _state == MazeState.STARTED:
		_stop_pending_player_revival()
		if _is_respawn_point_safe_for_the_player():
			_player.revive(_respawn_point_map_pos())
		else:
			_delay_player_revival()


func is_empty_tile(map_pos: Vector2i) -> bool:
	return get_cell_source_id(map_pos) == -1


func get_surrounding_empty_cells(map_pos: Vector2i) -> Array[Vector2i]:
	var surrounding_cells: Array[Vector2i] = get_surrounding_cells(map_pos)
	return surrounding_cells.filter(func(item):
		return is_empty_tile(item)
	)


func global_to_map(global_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(global_pos))


func _is_respawn_point_safe_for_the_player() -> bool:
	var tile_size: Vector2i = tile_set.tile_size
	var spawn_point_rect := Rect2(_respawn_pos_marker.position, tile_size)
	var blue_ghost_rect := Rect2(_blue_ghost.position, tile_size)
	var red_ghost_rect := Rect2(_red_ghost.position, tile_size)
	var yellow_ghost_rect := Rect2(_yellow_ghost.position, tile_size)
	return not [blue_ghost_rect, red_ghost_rect, yellow_ghost_rect].any(
		func(item: Rect2): return item.intersects(spawn_point_rect)
	)


func _is_player_near_respawn_point() -> bool:
	var respawn_point : Vector2i = _respawn_point_map_pos()
	var cells: Array[Vector2i] = get_surrounding_empty_cells(respawn_point)
	cells.append(respawn_point)
	var rects := cells.map(func(item: Vector2i): 
		return Rect2i(item, Vector2i.ONE)
	)
	var player_rect := Rect2i(_player_map_pos(), Vector2i.ONE) 
	return rects.any(func(item: Rect2i): 
		return item.intersects(player_rect)
	)


func _respawn_point_map_pos() -> Vector2i:
	return local_to_map(_respawn_pos_marker.position)


func _player_map_pos() -> Vector2i:
	return local_to_map(_player.position)


func _delay_player_revival() -> void:
	_player_revival_delay_timer.start(RESPAWN_RETRY_DELAY_SECONDS)


func _reset_player() -> void:
	_player.reset(local_to_map(_player_init_pos_marker.position))


func _reset_ghost(ghost: Day02Enemy) -> void:
	ghost.reset(_respawn_point_map_pos())


func _reset_food() -> void:
	for item: Node2D in _food_node.get_children():
		item.visible = true


func _reset_all_ghosts() -> void:
	_reset_ghost(_blue_ghost)
	_reset_ghost(_red_ghost)
	_reset_ghost(_yellow_ghost)


func _stop_pending_player_revival() -> void:
	_player_revival_delay_timer.stop()


func _stop_pending_ghost_first_spawn() -> void:
	_red_ghost_first_spawn_timer.stop()
	_yellow_ghost_first_spawn_timer.stop()


func _stop_pending_ghost_respawn() -> void:
	_blue_ghost_respawn_timer.stop()
	_red_ghost_respawn_timer.stop()
	_yellow_ghost_respawn_timer.stop()


func _halt_all_ghosts() -> void:
	_blue_ghost.is_halt = true
	_red_ghost.is_halt = true
	_yellow_ghost.is_halt = true


func _halt_player() -> void:
	_player.is_movement_allowed = false


func _scare_all_ghosts() -> void:
	_blue_ghost.get_scared()
	_red_ghost.get_scared()
	_yellow_ghost.get_scared()


func _count_food() -> int:
	return Utils.count(_food_node.get_children(), func(item):
		return item.visible
	)


func _check_maze_completion() -> void:
	if _state == MazeState.FAILED:
		return
	
	var remaining_food: int = _count_food()
	var is_maze_completed: bool = remaining_food <= 0
	if is_maze_completed:
		_stop_pending_ghost_first_spawn()
		_stop_pending_ghost_respawn()
		_halt_all_ghosts()
		_halt_player()
		_maze_bgm.stop()
		_state = MazeState.COMPLETED
		completed.emit()


func _revive_ghost(ghost: Node2D) -> void:
	_reset_ghost(ghost)
	ghost.is_halt = false


func _start_ghost_respawn_timer(timer: Timer) -> void:
	timer.start(GHOST_RESPAWN_DELAY_SECONDS)


func _on_blue_ghost_speed_set() -> void:
	if is_node_ready():
		_blue_ghost.speed = blue_ghost_speed


func _on_red_ghost_speed_set() -> void:
	if is_node_ready():
		_red_ghost.speed = red_ghost_speed


func _on_yellow_ghost_speed_set() -> void:
	if is_node_ready():
		_yellow_ghost.speed = yellow_ghost_speed


func _on_blue_ghost_dead() -> void:
	_start_ghost_respawn_timer(_blue_ghost_respawn_timer)


func _on_red_ghost_dead() -> void:
	_start_ghost_respawn_timer(_red_ghost_respawn_timer)


func _on_yellow_ghost_dead() -> void:
	_start_ghost_respawn_timer(_yellow_ghost_respawn_timer)


func _on_blue_ghost_respawn_timer_timeout() -> void:
	if _is_player_near_respawn_point():
		_blue_ghost_respawn_timer.start(RESPAWN_RETRY_DELAY_SECONDS)
	else:
		_revive_ghost(_blue_ghost)


func _on_red_ghost_respawn_timer_timeout() -> void:
	if _is_player_near_respawn_point():
		_red_ghost_respawn_timer.start(RESPAWN_RETRY_DELAY_SECONDS)
	else:
		_revive_ghost(_red_ghost)


func _on_yellow_ghost_respawn_timer_timeout() -> void:
	if _is_player_near_respawn_point():
		_yellow_ghost_respawn_timer.start(RESPAWN_RETRY_DELAY_SECONDS)
	else:
		_revive_ghost(_yellow_ghost)


func _on_red_ghost_first_spawn_timer_timeout() -> void:
	_red_ghost.is_halt = false


func _on_yellow_ghost_first_spawn_timer_timeout() -> void:
	_yellow_ghost.is_halt = false


func _on_player_revival_delay_timer_timeout() -> void:
	revive_player()


func _on_enemy_chomped() -> void:
	ghost_eaten.emit()


func _on_day_02_player_dying() -> void:
	player_dying.emit()


func _on_day_02_player_died() -> void:
	player_died.emit()


func _on_day_02_player_ate_regular_treat() -> void:
	treat_eaten.emit()
	_check_maze_completion()


func _on_day_02_player_ate_super_treat() -> void:
	super_treat_eaten.emit()
	_check_maze_completion()
	_scare_all_ghosts()
