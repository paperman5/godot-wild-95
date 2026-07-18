extends StaticBody2D

@onready var anim := %AnimationPlayer as AnimationPlayer
var on := false

func _ready() -> void:
	bump.call_deferred(Vector2.ZERO)

func bump(_from_dir : Vector2):
	set_on(not on)

func set_on(value : bool):
	on = value
	if not value:
		anim.play("off")
		anim.seek(0.0, true)
		anim.pause()
		on = false
		MusicManager.music_pause()
	else:
		anim.play("playing")
		anim.seek(0.0, true)
		anim.pause()
		on = true
		MusicManager.music_resume()
