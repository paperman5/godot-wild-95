extends Node2D

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimationPlayer = $AnimationPlayer

var amt_cooking := 0

func _on_food_dispenser_cooking_done() -> void:
	amt_cooking -= 1
	update_anim()


func _on_food_dispenser_started_cooking() -> void:
	audio.play()
	amt_cooking += 1
	update_anim()

func update_anim():
	if amt_cooking == 0:
		anim.current_animation = "idle"
		anim.seek(0.0, true)
	else:
		anim.current_animation = "cooking"
		anim.seek(0.0, true)
