extends TileMap


signal completed

const Day02Enemy = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")
const Day02Player = preload("res://scenes/day_02/_shared/player/day_02_player.gd")

const GHOST_RESPAWN_DELAY_SECONDS: float = 3.0
const PLAYER_RESPAWN_DELAY_SECONDS: float = 3.0
const BLUE_GHOST_MOVEMENT_DELAY_SECONDS: float = 0.5
const YELLOW_GHOST_MOVEMENT_DELAY_SECONDS: float = 1.0

var _is_reset := true

@onready var _is_ready := true
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


func _ready() -> void:
	if get_parent() == $/root:
		reset()
		start()


func reset() -> void:
	_reset_player()
	_reset_all_ghosts()
	_reset_food()
	visible = true
	_is_reset = true


func start() -> void:
	if _is_reset:
		_revive_ghost(_red_ghost)
		_blue_ghost_respawn_timer.start(BLUE_GHOST_MOVEMENT_DELAY_SECONDS)
		_yellow_ghost_respawn_timer.start(YELLOW_GHOST_MOVEMENT_DELAY_SECONDS)


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


func _stop_ghost_respawn() -> void:
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


func _is_maze_completed() -> bool:
	var remaining_food: int = _count_food()
	print("remaining_food: ", remaining_food)
	return remaining_food <= 0


func _check_maze_completion() -> void:
	if _is_maze_completed():
		_stop_ghost_respawn()
		_halt_all_ghosts()
		_halt_player()
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


func _on_enemy_chomped() -> void:
	print("TODO: Inform game so it can update the score")


func _on_day_02_player_ate_regular_treat() -> void:
	_check_maze_completion()


func _on_day_02_player_ate_super_treat() -> void:
	_check_maze_completion()
	_scare_all_ghosts()


func _on_visibility_changed() -> void:
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
