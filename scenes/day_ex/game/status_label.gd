extends Label


const StatusDisplayManager = preload("res://scenes/day_ex/game/status_display_manager.gd")

const SHORT_NAMES: Dictionary[StatusDisplayManager.Status, String] = {
	StatusDisplayManager.Status.NORMAL: "RPG_BATTLE_STATUS_EFFECT_SHORT_NORMAL",
	StatusDisplayManager.Status.POISON: "RPG_BATTLE_STATUS_EFFECT_SHORT_POISON",
	StatusDisplayManager.Status.CHARMED: "RPG_BATTLE_STATUS_EFFECT_SHORT_CHARMED",
	StatusDisplayManager.Status.ATK_BUFF: "RPG_BATTLE_STATUS_EFFECT_SHORT_ATTACK_BUFF",
	StatusDisplayManager.Status.ATK_DEBUFF: "RPG_BATTLE_STATUS_EFFECT_SHORT_ATTACK_DEBUFF",
	StatusDisplayManager.Status.DEF_BUFF: "RPG_BATTLE_STATUS_EFFECT_SHORT_DEFENSE_BUFF",
	StatusDisplayManager.Status.DEF_DEBUFF: "RPG_BATTLE_STATUS_EFFECT_SHORT_DEFENSE_DEBUFF",
	StatusDisplayManager.Status.SPD_BUFF: "RPG_BATTLE_STATUS_EFFECT_SHORT_SPEED_BUFF",
	StatusDisplayManager.Status.SPD_DEBUFF: "RPG_BATTLE_STATUS_EFFECT_SHORT_SPEED_DEBUFF",
}


func _ready() -> void:
	text = ""


func display_status(status: int) -> void:
	text = SHORT_NAMES.get(status)
