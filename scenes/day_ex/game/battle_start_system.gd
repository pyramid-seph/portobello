extends Node

signal start_battle


const DayExPlayer = preload("res://scenes/day_ex/player/day_ex_player.gd")

@export var time_before_battle: float

@onready var player: DayExPlayer = $"../../World/TileMap/DayExPlayer"


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	if time_before_battle > 0.0 \
			and player and player.get_walking_time() >= time_before_battle:
		set_process(false)
		player.reset_walking_time()
		start_battle.emit()


func reset(time_sec: float = 0.0):
	if time_sec > 0.0:
		time_before_battle = time_sec
	player.reset_walking_time()
	set_process(true)


func disable() -> void:
	set_process(false)


func is_disabled() -> bool:
	return is_processing()
