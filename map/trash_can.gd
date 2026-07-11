class_name TrashCan
extends StaticBody2D


func bump(from_dir : Vector2):
	GameManager.player.pop_food_stack()
