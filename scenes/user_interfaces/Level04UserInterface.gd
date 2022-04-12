extends Control

onready var score := $Score
onready var hi_score := $HiScore


func _ready() -> void:
	hi_score.text %= 0
	PlayerData.connect("score_updated", self, "_on_PlayerData_score_updated")


func _on_PlayerData_score_updated() -> void:
	score.text = str(PlayerData.score)
