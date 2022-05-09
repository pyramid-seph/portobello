extends Node

signal score_changed(new_val)
signal hi_score_changed(new_val)
signal time_left_changed(new_val)
signal lives_left_changed(new_val)
signal power_up_changed(new_val)

export(Resource) var player_data

onready var timer = $Timer


func _ready() -> void:
	player_data.connect("score_updated", self, "_on_playerData_score_updated")
	player_data.connect("hi_score_updated", self, "_on_playerData_hi_score_updated")
	player_data.connect("power_up_count_updated", self, "_on_playerData_power_up_count_updated")
	player_data.connect("remaining_lives_updated", self, "_on_playerData_remaining_lives_updated")

	_on_playerData_score_updated()
	_on_playerData_hi_score_updated()
	_on_playerData_remaining_lives_updated()
	_on_playerData_power_up_count_updated()
	_signal_time_update()


func _process(_delta):
	_signal_time_update()


func _signal_time_update():
	emit_signal("time_left_changed", timer.time_left)


func _on_playerData_score_updated() -> void:
	emit_signal("score_changed", player_data.score)


func _on_playerData_hi_score_updated() -> void:
	emit_signal("hi_score_changed", player_data.hi_score)


func _on_playerData_power_up_count_updated() -> void:
	emit_signal("power_up_changed", player_data.power_up_count)


func _on_playerData_remaining_lives_updated() -> void:
	emit_signal("lives_left_changed", player_data.lives)
