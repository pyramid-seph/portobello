extends Day03BossFight

@export var _player: Day03Player
@export var Hive: PackedScene

var _boss: Node2D

@onready var _world := $"../World" as Node2D
@onready var _stamina_spawner := $"../Systems/StaminaSpawner"
@onready var _power_up_spawner := $"../Systems/PowerUpSpawner"
@onready var _ui := $"../Interface/Day03Ui" as Day03Ui
@onready var _start_marker := $"../World/WavePhaseStartMarker" as Marker2D
@onready var _boss_bgm: Day03InteractiveBgmTemp = $Day03InteractiveBgm


func prepare() -> void:
	_boss = Hive.instantiate()
	_world.add_child(_boss)
	_boss.world = _world
	_boss.died.connect(_on_hive_dead)
	_boss.almost_dead.connect(_on_hive_almost_dead)
	_player.position = _start_marker.position
	_player.reset_physics_interpolation()
	_ui.change_bars_visibility(false)
	_ui.change_score_visibility(false)


func start() -> void:
	_play_boss_introduction()


func _play_boss_introduction() -> void:
	_boss_bgm.play_music()
	_boss.position.y = (3 + _boss.body_height()) * -1
	_boss.position.x =  _world.get_viewport_rect().size.x / 2 - 30
	_ui.start_main_course_presentation()
	var tween = create_tween()
	tween.tween_property(_boss, "position:y", 3.0, 4.32).set_trans(Tween.TRANS_LINEAR)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tween.finished.connect(_start_boss_fight, CONNECT_ONE_SHOT)


func _start_boss_fight() -> void:
	_ui.change_bars_visibility(true)
	_ui.change_score_visibility(true)
	_player.start_timed_invincibility()
	_player.is_input_enabled = true
	_stamina_spawner.enable(_world)
	_stamina_spawner.cooldown = Utils.FRAME_TIME
	_stamina_spawner.random = false
	_player.is_losing_stamina = true
	_boss.start()


func _on_hive_dead() -> void:
	_boss_bgm.stop_music()
	completed.emit()


func _on_hive_almost_dead() -> void:
	_power_up_spawner.enable(_world)
	_power_up_spawner.cooldown = Utils.FRAME_TIME
	_power_up_spawner.random = false
