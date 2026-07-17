class_name WinLoseMenus
extends Control

@onready var win_menu := %WinMenu as Control
@onready var lose_menu := %LoseMenu as Control
@onready var begin_menu := %BeginMenu as Control
@onready var pause_menu := %PauseMenu as Control

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

func _on_main_menu_pressed():
	GameManager.change_scene("main_menu")


func _on_next_pressed() -> void:
	GameManager.change_scene(GameManager.level.next_level)


func _on_retry_pressed() -> void:
	GameManager.reload_current_scene()
