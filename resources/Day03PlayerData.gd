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

var score: int = 0 :
	get:
		return score
	set(mod_value):
		score = mod_value
		emit_signal("score_updated")

var hi_score: int = 0 :
	get:
		return hi_score
	set(mod_value):
		hi_score = mod_value
		emit_signal("hi_score_updated")

var lives: int = MAX_LIVES :
	get:
		return lives
	set(mod_value):
		lives = clampi(mod_value, 0, MAX_LIVES)
		emit_signal("remaining_lives_updated")

var stamina: int = MAX_STAMINA :
	get:
		return stamina
	set(mod_value):
		stamina = clampi(mod_value, 0, MAX_STAMINA)
		print("Timmy: %s" % stamina)
		emit_signal("stamina_updated")

var power_up_count: int = 0 :
	get:
		return power_up_count
	set(mod_value):
		power_up_count = clampi(mod_value, 0, MAX_POWER_UP)
		emit_signal("power_up_count_updated")


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


func maximize_power_up() -> void:
	self.power_up_count = MAX_POWER_UP


func is_power_up_maximized() -> bool:
	return self.power_up_count == MAX_POWER_UP
