extends Node

signal score_changed(new_val)
signal hi_score_changed(new_val)
signal lives_left_changed(new_val)
signal power_up_changed(new_val)
signal stamina_changed(new_val, max_val)

export(Resource) var player_data


func _ready() -> void:
	player_data.connect("score_updated", self, "_on_player_data_score_updated")
	player_data.connect("hi_score_updated", self, "_on_player_data_hi_score_updated")
	player_data.connect("power_up_count_updated", self, "_on_player_data_power_up_count_updated")
	player_data.connect("remaining_lives_updated", self, "_on_player_data_remaining_lives_updated")
	player_data.connect("stamina_updated", self, "_on_player_data_remaining_stamina_updated")

	_on_player_data_score_updated()
	_on_player_data_hi_score_updated()
	_on_player_data_remaining_lives_updated()
	_on_player_data_power_up_count_updated()


func _on_player_data_score_updated() -> void:
	emit_signal("score_changed", player_data.score)


func _on_player_data_hi_score_updated() -> void:
	emit_signal("hi_score_changed", player_data.hi_score)


func _on_player_data_power_up_count_updated() -> void:
	emit_signal("power_up_changed", player_data.power_up_count, player_data.MAX_POWER_UP)


func _on_player_data_remaining_lives_updated() -> void:
	emit_signal("lives_left_changed", player_data.lives)


func _on_player_data_remaining_stamina_updated() -> void:
	emit_signal("stamina_changed", player_data.stamina, player_data.MAX_STAMINA)
