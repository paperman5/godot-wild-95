class_name WinLoseMenus
extends Control

@onready var win_menu := %WinMenu as Control
@onready var lose_menu := %LoseMenu as Control
@onready var begin_menu := %BeginMenu as Control
@onready var pause_menu := %PauseMenu as Control
@onready var level_name: Label = %LevelName
@onready var target_score: Label = %TargetScore
@onready var background_dimmer: ColorRect = %BackgroundDimmer


func _ready() -> void:
	show()
	hide_all()
	GameManager.menus = self

func show_win():
	hide_all()
	win_menu.show()

func show_lose():
	hide_all()
	lose_menu.show()

func show_begin():
	hide_all()
	begin_menu.show()

func show_pause():
	hide_all()
	pause_menu.show()

func hide_all():
	for c in get_children():
		c.hide()

func _on_begin_resume_pressed():
	hide_all()
	GameManager.level.unpause()
	if TutorialManager.do_intro_tutorial and GameManager.level.name in ["Tutorial", "Level1"]:
		var t := get_tree().create_timer(0.5)
		t.timeout.connect(TutorialManager.begin_tutorial.bind(TutorialManager.tutorials['intro']))
		TutorialManager.do_intro_tutorial = false
	if TutorialManager.do_food_tutorial and GameManager.level.name == "Level3":
		var t := get_tree().create_timer(0.5)
		t.timeout.connect(TutorialManager.begin_tutorial.bind(TutorialManager.tutorials['food']))
		TutorialManager.do_food_tutorial = false

func dim_background():
	var t = create_tween()
	t.tween_callback(background_dimmer.show)
	t.tween_property(background_dimmer, "modulate:a", 1.0, 0.2)

func undim_background():
	var t = create_tween()
	t.tween_property(background_dimmer, "modulate:a", 0.0, 0.2)
	t.tween_callback(background_dimmer.hide)

func _on_main_menu_pressed():
	GameManager.change_scene("main_menu")


func _on_next_pressed() -> void:
	GameManager.go_to_next_level()


func _on_retry_pressed() -> void:
	GameManager.reload_current_scene()

func set_level_name(new_name : String):
	level_name.text = new_name

func set_target_score(new_score : int):
	target_score.text = "Target Score: $%d" % new_score
