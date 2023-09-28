extends TileMap


signal completed
signal ghost_eaten
signal treat_eaten
signal super_treat_eaten
signal player_dying
signal player_died

enum MazeState {
	LOL,
	RESET,
	STARTED,
	FAILED,
	COMPLETED,
}

const Day02Enemy = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")
const Day02Player = preload("res://scenes/day_02/_shared/player/day_02_player.gd")

const GHOST_RESPAWN_DELAY_SECONDS: float = 3.0
const PLAYER_RESPAWN_DELAY_SECONDS: float = 3.0
const RED_GHOST_MOVEMENT_DELAY_SECONDS: float = 0.5
const YELLOW_GHOST_MOVEMENT_DELAY_SECONDS: float = 1.0

var _state: MazeState

@onready var _player_init_pos_marker = $PlayerInitPosMarker as Marker2D
@onready var _respawn_pos_marker = $RespawnPosMarker as Marker2D
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


func _ready() -> void:
	if get_parent() == $/root:
		reset()
		start()


func reset() -> void:
	_stop_pending_ghost_respawn()
	_stop_pending_ghost_first_spawn()
	_reset_player()
	_reset_all_ghosts()
	_reset_food()
	visible = true
	_state = MazeState.RESET


func start() -> void:
	if _state == MazeState.RESET:
		_player.is_movement_allowed = true
		_blue_ghost.is_halt = false
		_red_ghost_first_spawn_timer.start(RED_GHOST_MOVEMENT_DELAY_SECONDS)
		_yellow_ghost_first_spawn_timer.start(YELLOW_GHOST_MOVEMENT_DELAY_SECONDS)
		_state = MazeState.STARTED


func failed() -> void:
	if _state == MazeState.STARTED:
		_stop_pending_ghost_first_spawn()
		_stop_pending_ghost_respawn()
		_halt_all_ghosts()
		_player.is_movement_allowed = false
		_state == MazeState.FAILED


func revive_player() -> void:
	if _state == MazeState.STARTED:
		# TODO Revive only when this maze is in state started and no enemy is respawning
		_player.revive(local_to_map(_respawn_pos_marker.position))


func is_empty_tile(map_pos: Vector2i) -> bool:
	return get_cell_source_id(0, map_pos) == -1


func get_surrounding_empty_cells(map_pos: Vector2i) -> Array[Vector2i]:
	var surrounding_cells := get_surrounding_cells(map_pos)
	return surrounding_cells.filter(func(item):
		return is_empty_tile(item)
	)


func _reset_player() -> void:
	_player.reset(local_to_map(_player_init_pos_marker.position))


func _reset_ghost(ghost: Day02Enemy) -> void:
	ghost.reset(local_to_map(_respawn_pos_marker.position))


func _reset_food() -> void:
	for item in _food_node.get_children():
		item.visible = true


func _reset_all_ghosts() -> void:
	_reset_ghost(_blue_ghost)
	_reset_ghost(_red_ghost)
	_reset_ghost(_yellow_ghost)


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
	pass # TODO


func _scare_all_ghosts() -> void:
	_blue_ghost.get_scared()
	_red_ghost.get_scared()
	_yellow_ghost.get_scared()


func _count_food() -> int:
	return Utils.count(_food_node.get_children(), func(item):
		return item.visible
	)


func _check_maze_completion() -> void:
	var remaining_food: int = _count_food()
	var is_maze_completed: bool = remaining_food <= 0
	if is_maze_completed:
		_stop_pending_ghost_first_spawn()
		_stop_pending_ghost_respawn()
		_halt_all_ghosts()
		_halt_player()
		_state = MazeState.COMPLETED
		completed.emit()


func _revive_ghost(ghost: Node2D) -> void:
	_reset_ghost(ghost)
	ghost.is_halt = false


func _start_ghost_respawn_timer(timer: Timer) -> void:
	timer.start(GHOST_RESPAWN_DELAY_SECONDS)


func _on_blue_ghost_dead() -> void:
	_start_ghost_respawn_timer(_blue_ghost_respawn_timer)


func _on_red_ghost_dead() -> void:
	_start_ghost_respawn_timer(_red_ghost_respawn_timer)


func _on_yellow_ghost_dead() -> void:
	_start_ghost_respawn_timer(_yellow_ghost_respawn_timer)


func _on_blue_ghost_respawn_timer_timeout() -> void:
	_revive_ghost(_blue_ghost)


func _on_red_ghost_respawn_timer_timeout() -> void:
	_revive_ghost(_red_ghost)


func _on_yellow_ghost_respawn_timer_timeout() -> void:
	_revive_ghost(_yellow_ghost)


func _on_red_ghost_first_spawn_timer_timeout() -> void:
	_red_ghost.is_halt = false


func _on_yellow_ghost_first_spawn_timer_timeout() -> void:
	_yellow_ghost.is_halt = false


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


func _on_visibility_changed() -> void:
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
