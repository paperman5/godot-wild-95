extends Node

var player : Player
var level : Level
var game_ui : GameUI
var menus : WinLoseMenus

const save_file_path := "user://savegame.txt"

const level_scenes = {
	"main_menu" : "uid://6kyebxi5bbkj",
	"test" : "uid://dk5rt65a0f75k"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	var zoom = get_viewport().get_camera_2d().zoom
	RenderingServer.global_shader_parameter_set("zoom", zoom)

func time_up():
	pass

func change_scene(new_scene : String):
	if new_scene == null or new_scene == "":
		push_warning("Scene not given")
	elif not new_scene in level_scenes.keys():
		push_warning("Scene %s doesn't have a target UID" % new_scene)
	else:
		get_tree().change_scene_to_file(level_scenes[new_scene])
		if new_scene != "main_menu":
			var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
			save_file.store_line(level_scenes[new_scene])
			save_file.close()

func change_scene_uid(uid : String):
	get_tree().change_scene_to_file(uid)
