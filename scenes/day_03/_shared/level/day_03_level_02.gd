extends Day03Level


@export var _boss: Node2D


func _prepare_boss() -> void:
	_boss.died.connect(_on_motership_dead)


func _play_boss_introduction() -> void:
	_timer.start(3.0)
	# Abduction
	await _timer.timeout
	# Black screen
	_boss.process_mode = Node.PROCESS_MODE_INHERIT
	_boss.visible = true
	_boss.abduct(_player)
	# alien dialog
	_timer.start(3.0)
	await _timer.timeout


func _start_boss_fight() -> void:
	# TODO
	
	pass


func _on_motership_dead() -> void:
	_on_level_complete()
