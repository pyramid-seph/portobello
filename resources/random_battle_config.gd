class_name RandomBattleConfig
extends Resource


@export var _id: String
@export var _background: Texture2D
@export var _enemy_parties: Array[BattleParty]


func get_id() -> String:
	return _id


func get_background() -> Texture2D:
	return _background


func get_random_party() -> BattleParty:
	var weights: Array[float] = []
	for party in _enemy_parties:
		weights.append(party.get_weigth())
	var selected_idx: int = Utils.rand_weigthed(weights)
	return _enemy_parties[selected_idx]
