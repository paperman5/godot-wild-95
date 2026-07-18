extends StaticBody2D

@onready var anim := %AnimationPlayer as AnimationPlayer
var on := true

func bump(_from_dir : Vector2):
	if on:
		anim.play("off")
		anim.seek(0.0, true)
		anim.pause()
		on = false
	else:
		anim.play("playing")
		anim.seek(0.0, true)
		anim.pause()
		on = true
	MusicManager.toggle_pause()
