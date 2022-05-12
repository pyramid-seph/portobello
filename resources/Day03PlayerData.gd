extends Resource
class_name Day03PlayerData

signal score_updated
signal hi_score_updated
signal power_up_count_updated
signal remaining_lives_updated
signal stamina_updated

const MAX_LIVES: int = 9
const MAX_STAMINA: int = 50
const MAX_POWER_UP: int = 5

var score: int = 0 setget set_score
var hi_score: int = 0 setget set_hi_score
var lives: int = MAX_LIVES setget set_lives
var stamina: int = MAX_STAMINA setget set_stamina
var power_up_count: int = 0 setget set_power_up_count


func reset():
	self.score = 0
	reset_stamina()
	reset_lives()
	reset_power_up()


func reset_stamina() -> void:
	self.stamina = MAX_STAMINA


func reset_lives() -> void:
	self.lives = MAX_LIVES


func reset_power_up() -> void:
	self.power_up_count = 0


func set_score(value) -> void:
	score = value
	emit_signal("score_updated")

	if score > hi_score:
		self.hi_score = score


func set_power_up_count(value: int) -> void:
	power_up_count = int(clamp(value, 0, MAX_POWER_UP))
	emit_signal("power_up_count_updated")


func set_hi_score(value: int) -> void:
	hi_score = value
	emit_signal("hi_score_updated")


func set_lives(value: int) -> void:
	lives = int(clamp(value, 0, MAX_LIVES))
	emit_signal("remaining_lives_updated")


func set_stamina(value: int) -> void:
	stamina = int(clamp(value, 0, MAX_STAMINA))
	emit_signal("stamina_updated")
