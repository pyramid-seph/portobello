extends TileMap


signal completed

const Day02Enemy = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")
const Day02Player = preload("res://scenes/day_02/_shared/player/day_02_player.gd")

const GHOST_RESPAWN_DELAY_SECONDS: float = 3.0
const PLYER_RESPAWN_DELAY_SECONDS: float = 3.0

@onready var _is_ready := true
@onready var _player_start_marker = $PlayerStartPos as Marker2D
@onready var _respawn_marker = $RespawnPos as Marker2D
@onready var _player := $Day02Player as Day02Player
@onready var _blue_ghost := $BlueGhost as Day02Enemy
@onready var _red_ghost := $RedGhost as Day02Enemy
@onready var _yellow_ghost := $YellowGhost as Day02Enemy
@onready var _food_node := $Food as Node
@onready var _blue_ghost_respawn_timer := $BlueGhostRespawnTimer as Timer
@onready var _red_ghost_respawn_timer := $RedGhostRespawnTimer as Timer
@onready var _yellow_ghost_respawn_timer := $YellowGhostRespawnTimer as Timer


func _ready() -> void:
	_place_player()
	_place_all_ghosts()
	_count_food()


func is_empty_tile(map_pos: Vector2i) -> bool:
	return get_cell_source_id(0, map_pos) == -1


func get_surrounding_empty_cells(map_pos: Vector2i) -> Array[Vector2i]:
	var surrounding_cells := get_surrounding_cells(map_pos)
	return surrounding_cells.filter(func(item):
		return is_empty_tile(item)
	)


func _place_player() -> void:
	_player.teleport(local_to_map(_player_start_marker.position))


func _place_ghosts(ghost: Day02Enemy) -> void:
	ghost.teleport(local_to_map(_respawn_marker.position))


func _place_all_ghosts() -> void:
	_place_ghosts(_blue_ghost)
	_place_ghosts(_red_ghost)
	_place_ghosts(_yellow_ghost)


func _stop_ghost_respawn() -> void:
	_blue_ghost_respawn_timer.stop()
	_red_ghost_respawn_timer.stop()
	_yellow_ghost_respawn_timer.stop()


func _halt_all_ghosts() -> void:
	_blue_ghost.halt()
	_red_ghost.halt()
	_yellow_ghost.halt()


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


func _revive_ghost(dead_ghost: Node2D) -> void:
	dead_ghost.revive(local_to_map(_respawn_marker.position))


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
