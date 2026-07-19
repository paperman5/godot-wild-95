extends Node

@export var next_scene := ""
@onready var skip: Button = $Control/Skip

func _ready() -> void:
	MusicManager.set_music_lofi(false)
	MusicManager.music_pause()
	if next_scene == "tutorial" and TutorialManager.skip_tutorials:
		next_scene = "level_1"


func _on_video_stream_player_finished() -> void:
	GameManager.change_scene(next_scene)


func _on_skip_pressed() -> void:
	GameManager.change_scene(next_scene)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		skip.show()
