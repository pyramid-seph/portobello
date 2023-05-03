extends Day03Level


@export var _boss: Node2D

var _tween: Tween


func _prepare_boss() -> void:
	_boss.world = _world
	_boss.died.connect(_on_hive_dead)
	_boss.almost_dead.connect(_on_hive_almost_dead)
	_boss.process_mode = Node.PROCESS_MODE_INHERIT


func _play_boss_introduction() -> void:
	_boss.position.y = (3 + _boss.body_height()) * -1
	_boss.position.x =  _world.get_viewport_rect().size.x / 2 - 30
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_boss, "position:y", 3.0, 4.32).set_trans(Tween.TRANS_LINEAR)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	await _tween.finished#.connect(_on_boss_introduction_played)


func _start_boss_fight() -> void:
	_stamina_spawner.enable(_world)
	_stamina_spawner.cooldown = Utils.FRAME_TIME
	_stamina_spawner.random = false
	_player.is_losing_stamina = true
	_boss.start()


func _on_hive_dead() -> void:
	_on_level_complete()


func _on_hive_almost_dead() -> void:
	_power_up_spawner.enable(_world)
	_power_up_spawner.cooldown = Utils.FRAME_TIME
	_power_up_spawner.random = false
