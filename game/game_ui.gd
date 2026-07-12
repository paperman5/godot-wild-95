class_name GameUI
extends CanvasLayer

@onready var money_label := %Money as Label
@onready var combo_base_label := %ComboBase as Label
@onready var combo_mult_label := %ComboMult as Label

func _ready() -> void:
	GameManager.game_ui = self

func set_money(value):
	money_label.text = "$" + str(value)

func set_combo(base : int, mult : float):
	combo_base_label.text = str(base)
	combo_mult_label.text = str(snappedf(mult, 0.01))
