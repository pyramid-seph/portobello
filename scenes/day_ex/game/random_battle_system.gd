extends Node

signal start_battle(enemy_party: BattleParty, background: Texture2D)


const DayExPlayer = preload("res://scenes/day_ex/player/day_ex_player.gd")

@export_range(1.0, 10.0, 0.1, "or_greater") var _min_time_sec: float = 1.0
@export_range(1.0, 10.0, 0.1, "or_greater") var _max_time_sec: float = 10.0
@export_group("Random Battles")
@export var _battle_configs: Array[RandomBattleConfig]

var _time_before_battle: float

@onready var _player: DayExPlayer = %DayExPlayer
@onready var _battle_config_tiles: TileMapLayer = %BattleConfigTileMapLayer


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	if _time_before_battle > 0.0 \
			and _player and _player.get_walking_time() > _time_before_battle:
		_player.reset_walking_time()
		var battle_id: String = _get_random_battle_id()
		var battle_config: RandomBattleConfig = Utils.first_or_null(
				_battle_configs, 
				func(config: RandomBattleConfig): 
						return config.get_id() == battle_id)
		if battle_config:
			set_process(false)
			start_battle.emit(battle_config.get_random_party(), \
					 battle_config.get_background())
		else:
			reset()


func reset():
	_randomize_time_before_battle()
	_player.reset_walking_time()
	set_process(true)


func disable() -> void:
	set_process(false)


func is_disabled() -> bool:
	return not is_processing()


func _randomize_time_before_battle() -> void:
	_time_before_battle = randf_range(_min_time_sec, _max_time_sec)


func _get_random_battle_id() -> String:
	var player_global_pos: Vector2 = _player.global_position
	var player_tilemap_local_pos: Vector2 = \
			_battle_config_tiles.to_local(player_global_pos)
	var cell_map_pos: Vector2i = \
			_battle_config_tiles.local_to_map(player_tilemap_local_pos)
	var tile_data: TileData = \
			_battle_config_tiles.get_cell_tile_data(cell_map_pos)
	if tile_data:
		return tile_data.get_custom_data(
				Constants.RPG_TILEMAP_CUSTOM_DATA_LAYER_RANDOM_BATTLE_ID)
	else:
		return ""
