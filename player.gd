extends Node2D

const TILE_SIZE = 32

@export var tile_move_speed := 0.1

@onready var spr := %AnimatedSprite as AnimatedSprite2D
var move_tween : Tween
var true_pos := Vector2.ZERO

func _ready() -> void:
	spr.play("idle_down")
	true_pos = position

func _physics_process(_delta: float) -> void:
	
	var move_dir := Vector2.ZERO
	if Input.is_action_just_pressed("move_down"):
		move_dir = Vector2.DOWN
		spr.play("idle_down")
	elif Input.is_action_just_pressed("move_up"):
		move_dir = Vector2.UP
		spr.play("idle_up")
	elif Input.is_action_just_pressed("move_left"):
		move_dir = Vector2.LEFT
		spr.play("idle_side")
		spr.flip_h = true
	elif Input.is_action_just_pressed("move_right"):
		move_dir = Vector2.RIGHT
		spr.play("idle_side")
		spr.flip_h = false
	
	if not move_dir.is_zero_approx():
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = true_pos + move_dir * TILE_SIZE
		var result = space_state.intersect_point(query, 1)
		if result:
			var colliding_obj := result[0]['collider'] as Node2D
			if colliding_obj.has_method("bump"):
				colliding_obj.bump(move_dir)
		else:
			true_pos += move_dir * TILE_SIZE
			_create_move_tween()

func _create_move_tween():
	if move_tween != null:
		move_tween.kill()

	move_tween = create_tween()
	move_tween.tween_property(self, "position", true_pos, tile_move_speed)
	
	
