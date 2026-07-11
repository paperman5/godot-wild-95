extends Node2D

const TILE_SIZE = 32

@export var tile_move_speed := 0.1
@export var move_cooldown := 0.075

@onready var spr := %Sprite2D as Sprite2D
@onready var anim := %AnimationPlayer as AnimationPlayer
var move_tween : Tween
var true_pos := Vector2.ZERO
var moving := false

func _ready() -> void:
	anim.play("idle_down")
	true_pos = position

func _physics_process(_delta: float) -> void:
	if moving:
		return
	
	var move_dir := Vector2.ZERO
	if Input.is_action_just_pressed("move_down"):
		move_dir = Vector2.DOWN
		anim.play("idle_down")
	elif Input.is_action_just_pressed("move_up"):
		move_dir = Vector2.UP
		anim.play("idle_up")
	elif Input.is_action_just_pressed("move_left"):
		move_dir = Vector2.LEFT
		anim.play("idle_left")
	elif Input.is_action_just_pressed("move_right"):
		move_dir = Vector2.RIGHT
		anim.play("idle_right")
	
	if not move_dir.is_zero_approx():
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = true_pos + move_dir * TILE_SIZE
		var result = space_state.intersect_point(query, 1)
		if result:
			var colliding_obj := result[0]['collider'] as Node2D
			if colliding_obj.has_method("bump"):
				colliding_obj.bump(move_dir)
			_create_move_tween(move_dir, true)
		else:
			true_pos += move_dir * TILE_SIZE
			_create_move_tween(move_dir, false)

func _create_move_tween(dir : Vector2, bump : bool):
	if move_tween != null:
		move_tween.kill()
	
	moving = true
	move_tween = create_tween().set_parallel(true)
	if not bump:
		move_tween.tween_property(self, "position", true_pos, tile_move_speed)
	else:
		move_tween.tween_property(self, "position", true_pos + TILE_SIZE*dir/2, tile_move_speed/2)
		move_tween.chain().tween_property(self, "position", true_pos, tile_move_speed/2)
	move_tween.tween_interval(move_cooldown)
	move_tween.chain().tween_callback(func(): moving = false)
	
	
