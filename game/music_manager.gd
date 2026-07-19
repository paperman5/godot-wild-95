extends Node

signal beat()

@export var music_lofi_hipass_amt := 2000
@export var music_lofi_drive := 0.5
@export var music_lofi_fade_time := 0.2
@export var music_volume_fade_time := 0.5
@export var extra_beats_per_beat := 0

var music_lofi_tweener : Tween
var music_fade_tween : Tween
var music_lofi_mode := false

var music_bus_idx : int
var sfx_bus_idx : int

var hipass_filter : AudioEffectHighPassFilter
var lofi_filter : AudioEffectDistortion

var music_bpm := 60.0
var beat_idx := 0
var playback_pos := 0.0
var next_beat := 0.0
var current_track : MultiBPMAudioStream
var latency := 0.0
var initial_music_volume := 0.0

@onready var music_player := %MusicPlayer as AudioStreamPlayer

func _ready() -> void:
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	hipass_filter = AudioServer.get_bus_effect(music_bus_idx, 1)
	lofi_filter = AudioServer.get_bus_effect(music_bus_idx, 2)
	latency = AudioServer.get_output_latency()
	initial_music_volume = AudioServer.get_bus_volume_linear(music_bus_idx)

func _process(delta: float) -> void:
	if current_track == null or not music_player.playing:
		return
	playback_pos += delta
	if playback_pos >= next_beat:
		beat_idx += 1
		next_beat = get_next_beat_time(playback_pos)
		beat.emit()
	if current_track.loop and playback_pos >= current_track.loop_end - latency:
		playback_pos = current_track.loop_start + playback_pos - current_track.loop_end
		playback_pos = maxf(0.0, playback_pos)
		music_player.seek(playback_pos)
		next_beat = get_next_beat_time(playback_pos)

func music_is_playing() -> bool:
	return current_track != null and music_player.playing

func music_pause():
	if music_player.playing:
		music_player.playing = false

func music_resume():
	if not music_player.playing and current_track != null:
		music_player.play(playback_pos)

func music_fade_out():
	if music_fade_tween != null:
		music_fade_tween.kill()
	music_fade_tween = create_tween()
	var current_vol = AudioServer.get_bus_volume_linear(music_bus_idx)
	music_fade_tween.tween_method(_set_music_bus_volume, current_vol, 0.01, music_volume_fade_time)

func music_fade_in():
	if music_fade_tween != null:
		music_fade_tween.kill()
	music_fade_tween = create_tween()
	var current_vol = AudioServer.get_bus_volume_linear(music_bus_idx)
	music_fade_tween.tween_method(_set_music_bus_volume, current_vol, initial_music_volume, music_volume_fade_time)

func _set_music_bus_volume(volume_linear : float):
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(volume_linear))

func get_next_beat_time(after_pos : float) -> float:
	var timestamps : Array[float] = current_track.bpm_ranges.keys()
	var bpms : Array[float] = current_track.bpm_ranges.values()
	if after_pos < timestamps[0]:
		return timestamps[0]
	var lbi := maxi(0, timestamps.bsearch(after_pos)-1)
	var n_prev_beats := floori((after_pos - timestamps[lbi]) * bpms[lbi] / 60.0)
	return float(n_prev_beats + 1) * 60.0 / bpms[lbi] + timestamps[lbi]

func set_music_lofi(enabled : bool):
	if not music_lofi_mode and enabled:
		if music_lofi_tweener == null:
			music_lofi_tweener = create_tween()
		music_lofi_mode = true
		music_lofi_tweener.kill()
		music_lofi_tweener = create_tween()
		music_lofi_tweener.set_parallel()
		music_lofi_tweener.tween_property(hipass_filter, "cutoff_hz", music_lofi_hipass_amt, music_lofi_fade_time)
		music_lofi_tweener.tween_property(lofi_filter, "drive", music_lofi_drive, music_lofi_fade_time)
	elif music_lofi_mode and not enabled:
		if music_lofi_tweener == null:
			music_lofi_tweener = create_tween()
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

func start_music(track : MultiBPMAudioStream):
	if current_track != null and track.stream == current_track.stream:
		return
	current_track = track.duplicate_deep()
	for t in current_track.bpm_ranges.keys():
		current_track.bpm_ranges[t] *= extra_beats_per_beat + 1
	music_bpm = maxf(20.0, track.bpm_ranges.values()[0])
	beat_idx = 0
	music_player.stream = track.stream
	next_beat = get_next_beat_time(0.0)
	playback_pos = 0.0
	music_player.play()

func set_music_muted(enabled : bool):
	AudioServer.set_bus_mute(music_bus_idx, enabled)
	
