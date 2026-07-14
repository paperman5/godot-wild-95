class_name MainMenu
extends Control

@onready var continue_button := %Continue as Button
@onready var newgame_button := %NewGame as Button
var continue_load := ""

func _ready() -> void:
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
	GameManager.change_scene("level_1")


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
