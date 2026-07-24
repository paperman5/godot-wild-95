extends Node

var player : Player
var level : Level
var game_ui : GameUI
var menus : WinLoseMenus
var default_view_size := Vector2.ZERO
var next_level := "tutorial"
var scene_transition_min_time := 0.75
var skip_cutscenes := false
var use_alt_sprites := false
var running_level_from_editor := false
var default_music_vol_db := 0.0
var music_vol_adjustment := 1.0
var default_sfx_vol_db := 0.0
var sfx_vol_adjustment := 1.0
var hold_to_move := false
var hold_to_move_speed := 0.15
var hold_speed_min := 0.1
var hold_speed_max := 0.2

const save_file_path := "user://savegame.txt"

const level_scenes = {
	"main_menu" : "uid://6kyebxi5bbkj",
	"test" : "uid://dk5rt65a0f75k",
	"tutorial" : "uid://brtt2pl2rmduv",
	"level_1" : "uid://ssywa7x2dhky",
	"level_2" : "uid://dnv7od3o7m2u",
	"level_3" : "uid://mufmt5bnk3bk",
	"cutscene" : "uid://g2lqs0suukre",
	"opening_video" : "uid://co5ieo3lw2l5m",
	"end_video" : "uid://becvipn7o3n22"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	default_view_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	running_level_from_editor = get_tree().current_scene.name != "MainMenu"
	default_music_vol_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	default_sfx_vol_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	#set_dialogic_filtering.call_deferred()

func _process(_delta: float) -> void:
	var cam = get_viewport().get_camera_2d()
	if is_instance_valid(cam):
		var view_scale = Vector2(get_window().size) / default_view_size
		var total_scale = Utils.get_view_scale()
		var zoom = cam.zoom
		RenderingServer.global_shader_parameter_set("zoom", zoom * view_scale)
		RenderingServer.global_shader_parameter_set("total_scale", total_scale)

func time_up():
	pass

func change_scene(new_scene : String):
	if new_scene == null or new_scene == "":
		push_warning("Scene not given")
	elif not new_scene in level_scenes.keys():
		push_warning("Scene %s doesn't have a target UID" % new_scene)
	else:
		var t = create_tween()
		t.tween_callback(TransitionManager.fade_out)
		t.tween_callback(MusicManager.music_fade_out)
		t.tween_await(TransitionManager.fade_complete)
		if MusicManager.music_fading:
			t.tween_await(MusicManager.music_fade_finished)
		t.tween_interval(scene_transition_min_time * Engine.time_scale)
		t.tween_callback(get_tree().change_scene_to_file.bind(level_scenes[new_scene]))
		t.tween_callback(TransitionManager.fade_in)
		t.tween_callback(MusicManager.music_fade_in)

func save_won(next_level_name):
	if next_level_name in ["level_1", "level_2", "level_3"]:
		save(next_level_name)

func save_file_exists() -> bool:
	return FileAccess.file_exists(save_file_path)

func save(scene):
	var data = {
		"scene" : scene,
		"skip_cutscenes" : skip_cutscenes,
		"skip_tutorials" : TutorialManager.skip_tutorials,
		"music_vol" : music_vol_adjustment,
		"sfx_vol" : sfx_vol_adjustment,
		"alt_symbols" : use_alt_sprites,
		"hold_to_move" : hold_to_move,
		"hold_speed" : hold_to_move_speed,
		"game_speed" : Engine.time_scale
	}
	var save_str = JSON.stringify(data)
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	save_file.store_line(save_str)
	save_file.close()

func load_save_file() -> bool:
	if not save_file_exists():
		return false
	var save_file := FileAccess.open(save_file_path, FileAccess.READ)
	var save_str := save_file.get_as_text()
	var data = JSON.parse_string(save_str)
	save_file.close()
	if data == null or not data is Dictionary:
		return false
	for key in data.keys():
		try_load_save_key(data, key)
	return true

func go_to_next_level():
	if is_instance_valid(level):
		next_level = level.next_level
	change_scene(next_level)

func reload_current_scene():
	get_tree().reload_current_scene()

func change_scene_uid(uid : String):
	get_tree().change_scene_to_file(uid)


func try_load_save_key(save_data : Dictionary, key : String):
	if not key in save_data:
		return
	match key:
		'scene':
			next_level = save_data[key]
		'skip_cutscenes':
			skip_cutscenes = save_data[key]
		'skip_tutorials':
			TutorialManager.skip_tutorials = save_data[key]
		'music_vol':
			music_vol_adjustment = save_data[key]
		'sfx_vol':
			sfx_vol_adjustment = save_data[key]
		'alt_symbols':
			use_alt_sprites = save_data[key]
		'hold_to_move':
			hold_to_move = save_data[key]
		'hold_speed':
			hold_to_move_speed = save_data[key]
		'game_speed':
			Engine.time_scale = save_data[key]
