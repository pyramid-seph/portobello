extends RefCounted


const EXPRECTED_ITEM_KEYS: Array[String] = [
	"level",
	"experience",
	"hp",
	"mp",
	"attack",
	"defense",
	"speed",
	"agility",
	"luck",
]


static func parse_json_text(json_text: String) -> Result:
	var result = Result.new()
	result.error = ERR_PARSE_ERROR
	
	var json = JSON.parse_string(json_text) as Array[Dictionary]
	if not json or json.any(_is_malformed_json_item):
		printerr("Cannot import stats progression curves: malformed json.")
		return result
	
	json.sort_custom(func(a: Dictionary, b: Dictionary) -> int:
			return a.level < b.level)
	
	var stats_progression = StatsProgression.new()
	for json_item: Dictionary in json:
		stats_progression._experience_curve.append(json_item.experience.to_int()) 
		stats_progression._hp_curve.append(json_item.hp.to_int())
		stats_progression._mp_curve.append(json_item.mp.to_int())
		stats_progression._attack_curve.append(json_item.attack.to_int())
		stats_progression._defense_curve.append(json_item.defense.to_int())
		stats_progression._speed_curve.append(json_item.speed.to_int())
		stats_progression._agility_curve.append(json_item.agility.to_int())
		stats_progression._luck_curve.append(json_item.luck.to_int())
	
	result.error = OK
	result.object = stats_progression
	return result


static func _is_malformed_json_item(json_item: Dictionary) -> bool:
	return not json_item.has_all(EXPRECTED_ITEM_KEYS) or \
			not json_item.level.is_valid_int() or \
			not json_item.experience.is_valid_int() or \
			not json_item.hp.is_valid_int() or \
			not json_item.mp.is_valid_int() or \
			not json_item.attack.is_valid_int() or \
			not json_item.defense.is_valid_int() or \
			not json_item.speed.is_valid_int() or \
			not json_item.agility.is_valid_int() or \
			not json_item.luck.is_valid_int()


class Result:
	var error: Error
	var object: StatsProgression
	
	func is_ok() -> bool:
		return error == OK
