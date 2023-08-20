extends TileMap


@onready var _player_start_marker: Node2D = $PlayerStartPos
@onready var _player_respawn_marker: Node2D = $PlayerRespawnPos
@onready var _player: Node2D = $Day02Player


func _ready() -> void:
	_player.position = _player_start_marker.position
