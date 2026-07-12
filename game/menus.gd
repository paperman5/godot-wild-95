class_name WinLoseMenus
extends Control

@onready var win_menu := %WinMenu as Control
@onready var lose_menu := %LoseMenu as Control

func _ready() -> void:
	win_menu.hide()
	lose_menu.hide()
	show()
	GameManager.menus = self

func show_win():
	lose_menu.hide()
	win_menu.show()

func show_lose():
	win_menu.hide()
	lose_menu.show()
