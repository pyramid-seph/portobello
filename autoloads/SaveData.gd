class_name SaveData
extends RefCounted

const VERSION: int = 1

var version: int = VERSION
var latest_day_completed: int = 0 # First day is 1. Lost chapter does not count.
var is_vibration_enabled: bool = true
var is_autofire_enabled: bool = true
var stars: Stars = Stars.new()
var high_scores: HighScores = HighScores.new()

func to_dictionary() -> Dictionary:
	return {
		"version": VERSION,
		"latest_day_completed": latest_day_completed,
		"is_vibration_enabled": is_vibration_enabled,
		"is_autofire_enabled": is_autofire_enabled,
		"stars": {
			"day_one": stars.day_one,
			"day_two": stars.day_two,
			"day_three": stars.day_three,
		},
		"high_scores": {
			"buff_one_a": high_scores.buff_one_a,
			"buff_one_b": high_scores.buff_one_b,
			"buff_one_c": high_scores.buff_one_c,
			"buff_one_d": high_scores.buff_one_d,
			"buff_two": high_scores.buff_two,
			"buff_three_a": high_scores.buff_three_a,
			"buff_three_b": high_scores.buff_three_b,
			"day_two": high_scores.day_two,
			"day_three": high_scores.day_three,
		},
	}


class HighScores extends RefCounted:
	var buff_one_a: int = 0
	var buff_one_b: int = 0
	var buff_one_c: int = 0
	var buff_one_d: int = 0
	var buff_two: int = 0
	var buff_three_a: int = 0
	var buff_three_b: int = 0
	var day_two: int = 0
	var day_three: int = 0

class Stars extends RefCounted:
	var day_one: int = 0
	var day_two: int = 0
	var day_three: int = 0
