extends TextureRect


const StatusDisplayManager = preload("res://scenes/day_ex/game/status_display_manager.gd")

const CHARMED_TEXTURE = preload("res://art/day_ex/battle_status_love.png")
const POISON_TEXTURE = preload("res://art/day_ex/battle_status_poison.png")
const ATK_BUFF_TEXTURE = preload("res://art/day_ex/battle_status_atk_buff.png")
const ATK_DEBUFF_TEXTURE = preload("res://art/day_ex/battle_status_atk_debuff.png")
const DEF_BUFF_TEXTURE = preload("res://art/day_ex/battle_status_def_buff.png")
const DEF_DEBUFF_TEXTURE = preload("res://art/day_ex/battle_status_def_debuff.png")
const SPD_BUFF_TEXTURE = preload("res://art/day_ex/battle_status_spd_buff.png")
const SPD_DEBUFF_TEXTURE = preload("res://art/day_ex/battle_status_spd_debuff.png")

const TEXTURES: Dictionary[StatusDisplayManager.Status, Texture2D] = {
	StatusDisplayManager.Status.NORMAL: null,
	StatusDisplayManager.Status.POISON: POISON_TEXTURE,
	StatusDisplayManager.Status.CHARMED: CHARMED_TEXTURE,
	StatusDisplayManager.Status.ATK_BUFF: ATK_BUFF_TEXTURE,
	StatusDisplayManager.Status.ATK_DEBUFF: ATK_DEBUFF_TEXTURE,
	StatusDisplayManager.Status.DEF_BUFF: DEF_BUFF_TEXTURE,
	StatusDisplayManager.Status.DEF_DEBUFF: DEF_DEBUFF_TEXTURE,
	StatusDisplayManager.Status.SPD_BUFF: SPD_BUFF_TEXTURE,
	StatusDisplayManager.Status.SPD_DEBUFF: SPD_DEBUFF_TEXTURE,
}


func _ready() -> void:
	texture = null


func display_status(status: int) -> void:
	texture = TEXTURES.get(status)
