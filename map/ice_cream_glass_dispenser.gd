class_name IceCreamGlassDispenser
extends StaticBody2D

func bump(_from_dir : Vector2):
	GameManager.player.add_empty_icecream()
