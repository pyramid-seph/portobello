extends Node

signal level_state_changed(new_state)
signal pause_state_changed(new_state)

const START_DURATION: float = 1.6
const TIME_BETWEEN_REVIVALS: float = 1.2
const GAME_OVER_DURATION: float = 3.2

export(PackedScene) var player
export(Resource) var player_data: Resource

onready var world := $World
onready var mega_gun_flash := $Interface/MegaGunFlash
onready var player_start_position = $World/StartPosition.position
onready var wave_manager := $WaveManager
onready var stamina_spawner := $StaminaSpawner
onready var power_up_spawner := $PowerUpSpawner
onready var scene_tree = get_tree()


enum LevelState { STARTING, PLAYING, GAME_OVER }

var level_state: int = LevelState.STARTING setget set_level_state


func _ready() -> void:
	randomize()
	_instantiate_player()
	self.level_state = LevelState.STARTING
	yield(scene_tree.create_timer(START_DURATION, false), "timeout")
	self.level_state = LevelState.PLAYING
	wave_manager.start(world)
	stamina_spawner.enable(world)
	power_up_spawner.enable(world)


func _instantiate_player() -> void:
	var new_player = player.instance()
	new_player.position = player_start_position
	new_player.connect("died", self, "_on_Player_died")
	new_player.connect("mega_gun_shot", mega_gun_flash, "_on_Player_mega_gun_shot")
	world.add_child(new_player)


func _game_over():
	self.level_state = LevelState.GAME_OVER
	wave_manager.cancel_wave()
	stamina_spawner.disable()
	power_up_spawner.disable()
	yield(scene_tree.create_timer(GAME_OVER_DURATION), "timeout")
	scene_tree.quit()


func _input(event):
	if level_state == LevelState.PLAYING and event.is_action_pressed("pause"): 
		scene_tree.paused = not scene_tree.paused
		emit_signal("pause_state_changed", scene_tree.paused)


func set_level_state(value):
	level_state = value
	emit_signal("level_state_changed", level_state)


func _on_Player_died(remaining_lives) -> void:
	if remaining_lives == 0:
		_game_over()
	else:
		yield(scene_tree.create_timer(TIME_BETWEEN_REVIVALS, false), "timeout")
		_instantiate_player()


func _on_WaveManager_wave_completed(wave_index: int) -> void:
	print("WAVE %s COMPLETED!" % str(wave_index))


func _on_WaveManager_all_waves_completed() -> void:
	stamina_spawner.disable()
	power_up_spawner.disable()


func _on_WaveManager_wave_started(wave_index: int) -> void:
	print("WAVE %s STARTED!" % str(wave_index))