class_name ComboText
extends RichTextLabel

var shown_price := 0:
	set(value):
		shown_price = value
		update_texts()
		if is_instance_valid(price_text_timer) and value > 0:
			price_text_timer.start(text_linger_time)
var shown_bonus := 1.0:
	set(value):
		shown_bonus = value
		update_texts()
		if is_instance_valid(bonus_text_timer) and not is_equal_approx(value, 1.0):
			bonus_text_timer.start(text_linger_time)
var final := false
var failed_order := false

@export var text_linger_time := 2.0
@export var matched_order_color := Color.WEB_GREEN
@export var failed_order_color := Color.FIREBRICK
@export var bonus_color := Color.GOLD

@onready var price_text_timer := %PriceTextTimer as Timer
@onready var bonus_text_timer := %BonusTextTimer as Timer

func update_texts():
	text = ""
	if shown_price > 0:
		var c := matched_order_color if not failed_order else failed_order_color
		text = "[color=#%02x%02x%02x]$%d[/color]" % [c.r8, c.g8, c.b8, shown_price]
	if not is_equal_approx(shown_bonus, 1.0):
		var c := bonus_color
		if text != "":
			text += "\n"
		text += "[color=#%02x%02x%02x]+%.2fx[/color]" % [c.r8, c.g8, c.b8, shown_bonus]
	if final and text == "":
		queue_free()


func _on_price_text_timer_timeout() -> void:
	shown_price = 0


func _on_bonus_text_timer_timeout() -> void:
	shown_bonus = 1.0
