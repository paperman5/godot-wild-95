class_name MainMenu
extends Control

@export var music : MultiBPMAudioStream

@onready var continue_button := %Continue as Button
@onready var newgame_button := %NewGame as Button
@onready var standard_menu_root: Control = %StandardMenuRoot
@onready var credits_menu_root: Control = %CreditsMenuRoot
@onready var options_menu_root: Control = %OptionsMenuRoot
@onready var clear_button: Button = %Clear
@onready var options_button: Button = %Options
@onready var skip_tutorials: CheckBox = %SkipTutorials
@onready var skip_cutscenes: CheckBox = %SkipCutscenes
@onready var music_volume_label: Label = %MusicVolumeLabel
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_label: Label = %SFXVolumeLabel
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var symbols: CheckBox = %Symbols
@onready var hold: CheckBox = %Hold
@onready var hold_speed_label: Label = %HoldSpeedLabel
@onready var hold_speed_slider: HSlider = %HoldSpeedSlider
@onready var game_speed_label: Label = %GameSpeedLabel
@onready var game_speed_slider: HSlider = %GameSpeedSlider

var continue_load := ""

func _ready() -> void:
	MusicManager.set_music_lofi(false)
	MusicManager.start_music(music)
	if FileAccess.file_exists(GameManager.save_file_path):
		continue_button.show()
		clear_button.show()
		var file = FileAccess.open(GameManager.save_file_path, FileAccess.READ)
		continue_load = file.get_line()
		file.close()
	else:
		continue_button.hide()
		clear_button.hide()
	credits_menu_root.hide()
	options_menu_root.hide()
	standard_menu_root.show()
	
	music_volume_slider.value = 100 * GameManager.music_vol_adjustment
	sfx_volume_slider.value = 100 * GameManager.sfx_vol_adjustment
	game_speed_slider.value = 100 * Engine.time_scale
	hold_speed_slider.value = lerp(100.0, 200.0, \
		inverse_lerp(GameManager.hold_speed_max, GameManager.hold_speed_min, GameManager.hold_to_move_speed))
	skip_cutscenes.set_pressed_no_signal(GameManager.skip_cutscenes)
	skip_tutorials.set_pressed_no_signal(TutorialManager.skip_tutorials)
	hold.set_pressed_no_signal(GameManager.hold_to_move)
	symbols.set_pressed_no_signal(GameManager.use_alt_sprites)

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
		clear_button.hide()


func _on_mute_toggled(toggled_on: bool) -> void:
	MusicManager.set_music_muted(toggled_on)


func _on_skip_tutorials_toggled(toggled_on: bool) -> void:
	TutorialManager.skip_tutorials = toggled_on


func _on_skip_cutscenes_toggled(toggled_on: bool) -> void:
	GameManager.skip_cutscenes = toggled_on


func _on_credits_pressed() -> void:
	standard_menu_root.hide()
	options_menu_root.hide()
	credits_menu_root.show()


func _on_back_pressed() -> void:
	standard_menu_root.show()
	options_menu_root.hide()
	credits_menu_root.hide()


func _on_options_pressed() -> void:
	standard_menu_root.hide()
	options_menu_root.show()
	credits_menu_root.hide()


func _on_music_volume_slider_value_changed(value: float) -> void:
	music_volume_label.text = "%d%%" % roundi(value)
	GameManager.music_vol_adjustment = value / 100.0
	var bus_vol_linear = db_to_linear(GameManager.default_music_vol_db) * value / 100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(bus_vol_linear))


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	sfx_volume_label.text = "%d%%" % roundi(value)
	GameManager.sfx_vol_adjustment = value / 100.0
	var bus_vol_linear = db_to_linear(GameManager.default_sfx_vol_db) * value / 100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(bus_vol_linear))


func _on_game_speed_slider_value_changed(value: float) -> void:
	game_speed_label.text = "%d%%" % roundi(value)
	Engine.time_scale = value / 100.0


func _on_symbols_toggled(toggled_on: bool) -> void:
	GameManager.use_alt_sprites = toggled_on


func _on_hold_toggled(toggled_on: bool) -> void:
	GameManager.hold_to_move = toggled_on


func _on_hold_speed_slider_value_changed(value: float) -> void:
	hold_speed_label.text = "%d%%" % roundi(value)
	GameManager.hold_to_move_speed = lerp(GameManager.hold_speed_max, GameManager.hold_speed_min, \
		inverse_lerp(hold_speed_slider.min_value, hold_speed_slider.max_value, value))
