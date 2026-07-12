extends Node

var player : Player
var level : Level
var game_ui : GameUI
var menus : WinLoseMenus

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func time_up():
	pass
