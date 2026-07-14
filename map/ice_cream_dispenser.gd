@tool
class_name IceCreamDispenser
extends StaticBody2D

var textures = {
	Utils.IceCreamType.BooBerry : preload("uid://t6gg6lvr2i6h"),
	Utils.IceCreamType.ShockALot : preload("uid://bh8moifp757g0"),
	Utils.IceCreamType.Vilenilla : preload("uid://dhyew8vygd2gu")
}

@export var type : Utils.IceCreamType:
	set(value):
		type = value
		if is_instance_valid(spr) and value in Utils.IceCreamColors:
			spr.texture = textures[value]

@export var counter_style : Utils.TableOrientation:
	set(value):
		counter_style = value
		if is_instance_valid(counter_spr):
			counter_spr.texture.region = Utils.TableTextureRegions[value]
			counter_spr.flip_h = Table.should_flip_texture(value)

@onready var spr := %Sprite as Sprite2D
@onready var counter_spr := %Counter as Sprite2D

func _ready() -> void:
	type = type
	counter_style = counter_style

func bump(from_dir : Vector2):
	if from_dir.normalized().is_equal_approx(Vector2.UP):
		GameManager.player.add_icecream_flavor(type)
