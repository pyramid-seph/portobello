extends Day03BossFight


@export var _player: Day03Player
@export var Motership: PackedScene

var _boss: Node2D

@onready var _world := $"../World" as Node2D
@onready var _stamina_spawner := $"../Systems/StaminaSpawner"
@onready var _power_up_spawner := $"../Systems/PowerUpSpawner"
@onready var _ui := $"../Interface/Day03Ui" as Day03Ui
@onready var _timer := $Timer as Timer
@onready var _player_abduction_timer := $PlayerAbductionTimer as Timer
@onready var _start_marker := $"../World/WavePhaseStartMarker" as Marker2D
@onready var _sea_bg := $"../World/Day03Bg"


func prepare() -> void:
	_boss = Motership.instantiate()
	_world.add_child(_boss)
	_boss.died.connect(_on_motership_died, CONNECT_ONE_SHOT)
	_player.position = _start_marker.position
	_ui.change_bars_visibility(false)
	_ui.change_score_visibility(false)
	_ui.change_lives_visibility(false)


func start() -> void:
	_play_boss_introduction()


func cleanup() -> void:
	_boss.stop_exploding()


func _play_boss_introduction() -> void:
	await _tween_motership_intro()
	_timer.start(1.6)
	await _timer.timeout
	_boss.start_abduction_ray()
	_timer.start(0.8)
	await _timer.timeout
	await _tween_player_abduction()
	_boss.stop_abduction_ray()
	_ui.change_black_screen_visibility(true)
	_sea_bg.process_mode = Node.PROCESS_MODE_DISABLED
	_sea_bg.visible = false
	_timer.start(0.8)
	await _timer.timeout
	_boss.position = Vector2.ZERO
	_boss.player = _player
	_ui.change_black_screen_visibility(false)
	_timer.start(0.8)
	await _timer.timeout
	_boss.introduce_alien()
	_timer.start(3.2)
	await _timer.timeout
	_ui.start_main_course_presentation(3.2)
	await _ui.main_course_presented
	_ui.change_lives_visibility(true)
	_start_boss_fight()


func _tween_motership_intro() -> Signal:
	var tween = create_tween()
	_boss.position = Vector2i(0, -312)
	tween.tween_property(_boss, "position:y", -281, 2.4)
	return tween.finished


func _tween_player_abduction() -> void:
	for i: int in 10:
		_player_abduction_timer.start(Utils.FRAME_TIME)
		await _player_abduction_timer.timeout
		if i % 2 == 0:
			_player.position.y += 2 * i
		else:
			_player.position.y += -4 * i
	
	for i: int in 10:
		_player_abduction_timer.start(Utils.FRAME_TIME)
		await _player_abduction_timer.timeout
		_player.position.y += -30 * i


func _start_boss_fight() -> void:
	_player.start_timed_invincibility()
	_player.is_input_enabled = true
	_boss.is_attacking = true


func _on_motership_died() -> void:
	completed.emit()
