@tool
class_name IceCreamGlassDispenser
extends StaticBody2D

@onready var spr := %Sprite2D as Sprite2D

@export var style : Utils.TableOrientation:
	set(value):
		style = value
		if is_instance_valid(spr):
			spr.texture.region = Utils.TableTextureRegions[value]
			spr.flip_h = Table.should_flip_texture(value)

func _ready() -> void:
	style = style

func bump(_from_dir : Vector2):
	GameManager.player.add_empty_icecream()
