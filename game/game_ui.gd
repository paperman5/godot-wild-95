class_name GameUI
extends CanvasLayer

@onready var money_label := %Money as Label
@onready var combo_base_label := %ComboBase as Label
@onready var combo_mult_label := %ComboMult as Label
@onready var dpad := %VirtualJoystickDX as VirtualJoystickDX
@onready var timer_ui := %Timer as TextureProgressBar

func _ready() -> void:
	GameManager.game_ui = self
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		dpad.show()
	else:
		dpad.show()
		#dpad.hide()

func set_money(value):
	money_label.text = "$" + str(value)

func set_combo(base : int, mult : float):
	combo_base_label.text = str(base)
	combo_mult_label.text = str(snappedf(mult, 0.01))

func set_max_time(max_time : float):
	timer_ui.max_value = max_time

func set_time_remaining(time : float):
	timer_ui.value = time
