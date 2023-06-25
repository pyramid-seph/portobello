class_name Day03PlayerData
extends Resource

signal score_updated
signal hi_score_updated
signal power_up_count_updated
signal remaining_lives_updated
signal stamina_updated

const MAX_LIVES: int = 9
const MAX_STAMINA: int = 50
const MAX_POWER_UP: int = 5

var score: int:
	set(value):
		score = maxi(value, 0)
		score_updated.emit()

var hi_score: int:
	set(value):
		hi_score = maxi(value, 0)
		hi_score_updated.emit()

var lives: int = MAX_LIVES:
	set(value):
		lives = clampi(value, 0, MAX_LIVES)
		remaining_lives_updated.emit()

var stamina: int = MAX_STAMINA:
	set(value):
		stamina = clampi(value, 0, MAX_STAMINA)
		stamina_updated.emit()

var power_up_count: int:
	set(value):
		power_up_count = clampi(value, 0, MAX_POWER_UP)
		power_up_count_updated.emit()


func reset():
	reset_score()
	reset_stamina()
	reset_lives()
	reset_power_up()


func reset_score() -> void:
	score = 0


func reset_stamina() -> void:
	stamina = MAX_STAMINA


func reset_lives() -> void:
	lives = MAX_LIVES


func reset_power_up() -> void:
	power_up_count = 0


func maximize_power_up() -> void:
	power_up_count = MAX_POWER_UP


func is_power_up_maximized() -> bool:
	return power_up_count == MAX_POWER_UP
