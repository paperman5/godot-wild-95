extends CanvasLayer

signal fade_complete

@onready var anim: AnimationPlayer = %AnimationPlayer

func fade_out():
	anim.play("fade_out")

func fade_in():
	anim.play("fade_in")


func _on_animation_finished(_anim_name: StringName) -> void:
	fade_complete.emit()
