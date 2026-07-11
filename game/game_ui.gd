class_name GameUI
extends CanvasLayer

@onready var money_label := %Money as Label

func _ready() -> void:
	GameManager.game_ui = self

func set_money(value):
	money_label.text = "$" + str(value)
