extends Node

signal score_updated
signal hi_score_updated
signal power_up_count_updated
signal remaining_lives_updated

var score := 0 setget set_score
var power_up_count := 0 setget set_power_up_count
var hi_score := 0 setget set_hi_score
var lives := 0 setget set_lives


func _ready():
	self.hi_score = 120
	self.lives = 9


func reset():
	score = 0


func set_score(value):
	score = value
	emit_signal("score_updated")

	if score > hi_score:
		self.hi_score = score


func set_power_up_count(value):
	power_up_count = int(clamp(value, 0, 5))
	emit_signal("power_up_count_updated")


func set_hi_score(value):
	hi_score = value
	emit_signal("hi_score_updated")


func set_lives(value):
	lives = int(clamp(value, 0, 9))
	emit_signal("remaining_lives_updated")
