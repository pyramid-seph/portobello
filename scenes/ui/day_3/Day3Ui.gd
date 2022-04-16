extends Node


signal score_changed(new_val)
signal hi_score_changed(new_val)
signal time_left_changed(new_val)
signal lives_left_changed(new_val)
signal power_up_changed(new_val)

onready var timer = $Timer


func _ready() -> void:
	PlayerData.connect("score_updated", self, "_on_PlayerData_score_updated")
	PlayerData.connect("hi_score_updated", self, "_on_PlayerData_hi_score_updated")
	PlayerData.connect("power_up_count_updated", self, "_on_PlayerData_power_up_count_updated")
	PlayerData.connect("remaining_lives_updated", self, "_on_PlayerData_remaining_lives_updated")

	_on_PlayerData_score_updated()
	_on_PlayerData_hi_score_updated()
	_on_PlayerData_remaining_lives_updated()
	_on_PlayerData_power_up_count_updated()
	_signal_time_update()


func _process(_delta):
	_signal_time_update()


func _signal_time_update():
	emit_signal("time_left_changed", timer.time_left)


func _on_PlayerData_score_updated() -> void:
	emit_signal("score_changed", PlayerData.score)


func _on_PlayerData_hi_score_updated() -> void:
	emit_signal("hi_score_changed", PlayerData.hi_score)


func _on_PlayerData_power_up_count_updated() -> void:
	emit_signal("power_up_changed", PlayerData.power_up_count)


func _on_PlayerData_remaining_lives_updated() -> void:
	emit_signal("lives_left_changed", PlayerData.lives)
