class_name TrashCan
extends StaticBody2D


func bump(_from_dir : Vector2) -> bool:
	GameManager.player.pop_food_stack()
	return true
