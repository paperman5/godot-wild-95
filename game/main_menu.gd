class_name MainMenu
extends Control

@export var music : MultiBPMAudioStream

@onready var continue_button := %Continue as Button
@onready var newgame_button := %NewGame as Button
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

func _on_continue_pressed() -> void:
	GameManager.change_scene_uid(continue_load)


func _on_new_game_pressed() -> void:
	if TutorialManager.skip_tutorials:
		GameManager.next_cutscene = "level1"
		GameManager.next_level = "level_1"
	else:
		GameManager.next_cutscene = "opening"
		GameManager.next_level = "tutorial"
	GameManager.change_scene("cutscene")


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
