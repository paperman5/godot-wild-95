class_name MusicSyncComponent
extends Node

@export var animation_player : AnimationPlayer
@export var advance_every_n_beats := 1
@export var starting_animation := ""
@export var reset_on_ready := true

var beat_idx := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.speed_scale = 0.0
	start_sync()
	MusicManager.beat.connect(_on_music_beat)

func start_sync():
	if reset_on_ready:
		var reset = "RESET"
		if starting_animation != "" and "/" in starting_animation:
			var lib = starting_animation.split("/")[0]
			reset = lib + "/RESET"
		animation_player.current_animation = reset
		animation_player.seek(0.0, true)
	if starting_animation != "":
		animation_player.current_animation = starting_animation

func _on_music_beat():
	beat_idx = (beat_idx + 1) % advance_every_n_beats
	if beat_idx != 0:
		return
	Utils.advance_animation_single_frame(animation_player)
