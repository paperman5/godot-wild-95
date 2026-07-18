class_name TrashCan
extends StaticBody2D

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func bump(_from_dir : Vector2) -> bool:
	var success = GameManager.player.pop_food_stack()
	if success:
		audio.play()
	return success
