class_name MainMenu
extends Control

@export var music : MultiBPMAudioStream

@onready var continue_button := %Continue as Button
@onready var newgame_button := %NewGame as Button
@onready var standard_menu_root: Control = %StandardMenuRoot
@onready var credits_menu_root: Control = %CreditsMenuRoot

var continue_load := ""

func _ready() -> void:
	MusicManager.set_music_lofi(false)
	MusicManager.start_music(music)
	if FileAccess.file_exists(GameManager.save_file_path):
		continue_button.show()
		var file = FileAccess.open(GameManager.save_file_path, FileAccess.READ)
		continue_load = file.get_line()
		file.close()
	else:
		continue_button.hide()
	credits_menu_root.hide()
	standard_menu_root.show()

func _on_continue_pressed() -> void:
	var to_load = ""
	for key in GameManager.level_scenes.keys():
		if GameManager.level_scenes[key] == continue_load:
			to_load = key
	if to_load != "":
		GameManager.change_scene(to_load)


func _on_new_game_pressed() -> void:
	TutorialManager.do_intro_tutorial = true
	TutorialManager.do_food_tutorial = true
	if GameManager.skip_cutscenes:
		if TutorialManager.skip_tutorials:
			GameManager.change_scene("level_1")
		else:
			GameManager.change_scene("tutorial")
	else:
		GameManager.change_scene("opening_video")
	
	if TutorialManager.skip_tutorials:
		GameManager.save("level_1")
	else:
		GameManager.save("tutorial")


func _on_credit_meta_clicked(meta: Variant) -> void:
	# open the link in a web browser.
	OS.shell_open(str(meta))


func _on_clear_pressed() -> void:
	if FileAccess.file_exists(GameManager.save_file_path):
		DirAccess.remove_absolute(GameManager.save_file_path)
		continue_load = "level_1"
		continue_button.hide()


func _on_mute_toggled(toggled_on: bool) -> void:
	MusicManager.set_music_muted(toggled_on)


func _on_skip_tutorials_toggled(toggled_on: bool) -> void:
	TutorialManager.skip_tutorials = toggled_on


func _on_skip_cutscenes_toggled(toggled_on: bool) -> void:
	GameManager.skip_cutscenes = toggled_on


func _on_credits_pressed() -> void:
	standard_menu_root.hide()
	credits_menu_root.show()


func _on_credits_back_pressed() -> void:
	standard_menu_root.show()
	credits_menu_root.hide()
