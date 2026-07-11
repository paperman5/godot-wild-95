@tool
class_name IceCreamDispenser
extends StaticBody2D

@export var type : Utils.IceCreamType:
	get:
		return type
	set(value):
		type = value
		if is_instance_valid(color_spr) and value in Utils.IceCreamColors:
			color_spr.modulate = Utils.IceCreamColors[value]

@onready var color_spr := %Color as Sprite2D

func _ready() -> void:
	type = type

func bump(from_dir : Vector2):
	if from_dir.normalized().is_equal_approx(Vector2.UP):
		GameManager.player.add_icecream_flavor(type)
