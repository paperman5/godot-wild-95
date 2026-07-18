class_name GameUI
extends CanvasLayer

@onready var money_label := %ScoreLabel as Label
@onready var combo_base_label := %ComboBase as RichTextLabel
@onready var combo_mult_label := %ComboMult as RichTextLabel
@onready var dpad := %VirtualJoystickDX as VirtualJoystickDX
@onready var timer_ui := %Timer as TextureProgressBar
@onready var combo_container := %ComboContainer as Control
@onready var score_display := %ScoreDisplay as Control
@onready var touchscreen_pause: TextureButton = %TouchscreenPause

var base_tween : Tween
var mult_tween : Tween

var _base := 0
var _combo := 1.0

func _ready() -> void:
	GameManager.game_ui = self
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		dpad.show()
		touchscreen_pause.show()
	else:
		dpad.hide()
		touchscreen_pause.hide()
	#dpad.show()
	#touchscreen_pause.show()
	set_money(0)
	set_combo(0, 1.0)

func set_money(value):
	money_label.text = str(value)

func set_combo(base : int, mult : float):
	_base = base
	_combo = mult
	if base > 0 and _base != base:
		create_base_tween()
	if mult > 1.0 and not is_equal_approx(_combo, mult):
		create_mult_tween()
	var ca = Utils.colors["matched"]
	var cb = Utils.colors["combo"]
	combo_base_label.text = "[color=%02x%02x%02x]%d[/color]" % [ca.r8, ca.g8, ca.b8, base]
	combo_mult_label.text = "[color=%02x%02x%02x]%.2f[/color]" % [cb.r8, cb.g8, cb.b8, mult]
	if _base == 0 and is_equal_approx(_combo, 1.0):
		combo_container.hide()
	else:
		combo_container.show()

func create_base_tween():
	if base_tween != null:
		base_tween.kill()
	base_tween = create_tween()
	base_tween.tween_property(combo_base_label, "offset_transform_scale", Vector2.ONE * 1.5, 0.02)
	base_tween.tween_property(combo_base_label, "offset_transform_scale", Vector2.ONE, 0.1)

func create_mult_tween():
	if mult_tween != null:
		mult_tween.kill()
	mult_tween = create_tween()
	mult_tween.tween_property(combo_mult_label, "offset_transform_scale", Vector2.ONE * 1.5, 0.02)
	mult_tween.tween_property(combo_mult_label, "offset_transform_scale", Vector2.ONE, 0.1)

func set_max_time(max_time : float):
	timer_ui.max_value = max_time

func set_time_remaining(time : float):
	timer_ui.value = time


func _on_touchscreen_pause_pressed() -> void:
	Input.action_press("pause")
	Input.action_release.call_deferred("pause")
