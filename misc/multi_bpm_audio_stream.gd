class_name MultiBPMAudioStream
extends Resource

@export var bpm_ranges : Dictionary[float, float] = {}
@export var loop := false
@export var loop_start := 0.0
@export var loop_end := 0.0
@export var stream : AudioStreamMP3
