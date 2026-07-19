class_name GameCamera
extends Camera2D

@export var spring_stop_left := 100.0
@export var spring_stop_right := 100.0
@export var spring_stiffness := 10.0

@onready var orig_pos := global_position

var player : Player

func _ready() -> void:
	(func(): player = GameManager.player).call_deferred()

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	if player.position.x < orig_pos.x - spring_stop_left:
		var diff = orig_pos.x - spring_stop_left - player.position.x
		position.x = orig_pos.x - diff * spring_stiffness
	elif player.position.x > orig_pos.x + spring_stop_right:
		var diff = player.position.x - (orig_pos.x + spring_stop_right)
		position.x = orig_pos.x + diff * spring_stiffness
	else:
		position.x = orig_pos.x
	
