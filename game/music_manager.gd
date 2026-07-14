extends Node

signal beat(bar : bool)

@export var music_lofi_hipass_amt := 2000
@export var music_lofi_drive := 0.5
@export var music_lofi_fade_time := 0.2

var music_lofi_tweener : Tween
var music_lofi_mode := false

var music_bus_idx : int
var sfx_bus_idx : int

var hipass_filter : AudioEffectHighPassFilter
var lofi_filter : AudioEffectDistortion

var music_bpm := 60.0
var beat_idx := 0
var beats_per_bar := 1

@onready var beat_timer := %BeatTimer as Timer
@onready var music_player := %MusicPlayer as AudioStreamPlayer

func _ready() -> void:
	music_lofi_tweener = create_tween()
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	hipass_filter = AudioServer.get_bus_effect(music_bus_idx, 1)
	lofi_filter = AudioServer.get_bus_effect(music_bus_idx, 2)
	
	start_music(preload("uid://crw2vhfvifdv0"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_music_lofi(enabled : bool):
	if not music_lofi_mode and enabled:
		music_lofi_mode = true
		music_lofi_tweener.kill()
		music_lofi_tweener = create_tween()
		music_lofi_tweener.set_parallel()
		music_lofi_tweener.tween_property(hipass_filter, "cutoff_hz", music_lofi_hipass_amt, music_lofi_fade_time)
		music_lofi_tweener.tween_property(lofi_filter, "drive", music_lofi_drive, music_lofi_fade_time)
	elif music_lofi_mode and not enabled:
		music_lofi_mode = false
		music_lofi_tweener.kill()
		music_lofi_tweener = create_tween()
		music_lofi_tweener.set_parallel()
		music_lofi_tweener.tween_property(hipass_filter, "cutoff_hz", 20, music_lofi_fade_time)
		music_lofi_tweener.tween_property(lofi_filter, "drive", 0.0, music_lofi_fade_time)

func _set_hipass_enabled(enabled : bool):
	AudioServer.set_bus_effect_enabled(music_bus_idx, 1, enabled)

func _set_lofi_enabled(enabled : bool):
	AudioServer.set_bus_effect_enabled(music_bus_idx, 2, enabled)

func start_music(track : AudioStreamMP3):
	music_bpm = maxf(20.0, track.bpm)
	beats_per_bar = maxi(1, track.bar_beats)
	beat_idx = 0
	music_player.stream = track
	beat_timer.start(60.0/music_bpm)
	music_player.play()

func _on_beat_timer_timeout() -> void:
	beat_idx += 1
	beat.emit(beat_idx % beats_per_bar == 0)

func set_music_muted(enabled : bool):
	AudioServer.set_bus_mute(music_bus_idx, enabled)
	
