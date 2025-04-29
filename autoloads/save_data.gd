class_name SaveData
extends RefCounted

signal is_autofire_enabled_changed(old_val, new_val)


const VERSION: int = 4

var version: int = VERSION
# First day is 1. "The lost chapter" does not count.
var latest_day_completed: int
var latest_unlocked_day_notified: int
var is_vibration_enabled := true
var is_autofire_enabled := true:
	set(value):
		var old_is_autofire_enabled = is_autofire_enabled
		is_autofire_enabled = value
		is_autofire_enabled_changed.emit(old_is_autofire_enabled, is_autofire_enabled)
var language: String = Utils.get_default_language()
var is_audio_enabled: bool = true
var stars := Stars.new()
var high_scores := HighScores.new()

func to_dictionary() -> Dictionary:
	return {
		"version": VERSION,
		"latest_day_completed": latest_day_completed,
		"latest_unlocked_day_notified": latest_unlocked_day_notified,
		"is_vibration_enabled": is_vibration_enabled,
		"is_autofire_enabled": is_autofire_enabled,
		"language": language,
		"is_audio_enabled": is_audio_enabled,
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

static func from_json(json: Dictionary) -> SaveData:
	var save_data := SaveData.new()
	save_data.version = json.version
	save_data.latest_day_completed = json.latest_day_completed
	save_data.latest_unlocked_day_notified = json.latest_unlocked_day_notified
	save_data.is_autofire_enabled = json.is_autofire_enabled
	save_data.is_vibration_enabled = json.is_vibration_enabled
	save_data.stars.day_one = json.stars.day_one
	save_data.stars.day_two = json.stars.day_two
	save_data.stars.day_three = json.stars.day_three
	save_data.high_scores.buff_one_a = json.high_scores.buff_one_a
	save_data.high_scores.buff_one_b = json.high_scores.buff_one_b
	save_data.high_scores.buff_one_c = json.high_scores.buff_one_c
	save_data.high_scores.buff_one_d = json.high_scores.buff_one_d
	save_data.high_scores.buff_two = json.high_scores.buff_two
	save_data.high_scores.buff_three_a = json.high_scores.buff_three_a
	save_data.high_scores.buff_three_b = json.high_scores.buff_three_b
	save_data.high_scores.day_two = json.high_scores.day_two
	save_data.high_scores.day_three = json.high_scores.day_three
	save_data.language = json.language
	save_data.is_audio_enabled = json.is_audio_enabled
	return save_data


class HighScores extends RefCounted:
	var buff_one_a: int
	var buff_one_b: int
	var buff_one_c: int
	var buff_one_d: int
	var buff_two: int
	var buff_three_a: int
	var buff_three_b: int
	var day_two: int
	var day_three: int


class Stars extends RefCounted:
	var day_one: int
	var day_two: int
	var day_three: int
	
	
	func average() -> int:
		var total_stars: int = day_one + day_two + day_three
		var average_stars: float = total_stars / 3.0
		return floori(average_stars)
