class_name Player
extends Node2D

signal held_item_changed(new : FoodItem)

const TILE_SIZE = 32

@export var tile_move_speed := 0.1
@export var move_cooldown := 0.05
@export var max_food_stack := 4

@onready var spr := %Sprite2D as Sprite2D
@onready var anim := %AnimationPlayer as AnimationPlayer
@onready var hand := %Hand as Marker2D
var move_tween : Tween
var true_pos := Vector2.ZERO
var moving := false
var beat_initialized := false

var food_stack : Array[FoodItem] = []

func _ready() -> void:
	GameManager.player = self
	anim.play("idle_down")
	true_pos = position
	MusicManager.beat.connect(_on_music_beat)

func _physics_process(_delta: float) -> void:
	if moving or GameManager.level.paused:
		return
	
	var move_dir := Vector2.ZERO
	if Input.is_action_just_pressed("move_down"):
		move_dir = Vector2.DOWN
		anim.play("walk_down")
	elif Input.is_action_just_pressed("move_up"):
		move_dir = Vector2.UP
		anim.play("walk_up")
	elif Input.is_action_just_pressed("move_left"):
		move_dir = Vector2.LEFT
		anim.play("walk_left")
	elif Input.is_action_just_pressed("move_right"):
		move_dir = Vector2.RIGHT
		anim.play("walk_right")
	
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
	
func holding_icecream() -> bool:
	return len(food_stack) > 0 and is_instance_of(food_stack[0], IceCream)

func holding_empty_icecream() -> bool:
	return holding_icecream() and food_stack[0].is_empty()

func holding_food() -> bool:
	return len(food_stack) > 0 and is_instance_of(food_stack[0], CookedFood)

func add_empty_icecream() -> bool:
	if len(food_stack) < max_food_stack:
		# If we already have an empty icecream don't add another one
		if holding_icecream() and food_stack[0].is_empty():
			return false
		var icecream = preload("uid://cg80er3ff08wp").instantiate()
		add_to_food_stack(icecream)
		return true
	return false

func add_icecream_flavor(flavor : Utils.IceCreamType):
	if holding_icecream() and not food_stack[0].is_full():
		food_stack[0].add_flavor(flavor)
		held_item_changed.emit(get_held_order())

func add_cooked_food(type : Utils.FoodType) -> bool:
	if len(food_stack) < max_food_stack:
		if holding_empty_icecream():
			return false
		var food := preload("uid://b6duh0virt7sy").instantiate() as CookedFood
		food.food_type = type
		add_to_food_stack(food)
		return true
	return false

func add_to_food_stack(new_food : FoodItem):
	new_food.highlightable = false
	food_stack.push_front(new_food)
	_restack_food()
	held_item_changed.emit(new_food)
	
func pop_food_stack():
	var food = food_stack.pop_front()
	_restack_food()
	held_item_changed.emit(get_held_order())
	if food != null:
		food.queue_free()

func _restack_food():
	for item in food_stack:
		if is_instance_valid(item.get_parent()):
			item.get_parent().remove_child(item)
			item.position = Vector2.ZERO
	if len(food_stack) <= 0:
		return
	hand.add_child(food_stack[0])
	var next_par := food_stack[0].stack_pos
	for i in range(1, len(food_stack)):
		next_par.add_child(food_stack[i])
		next_par = food_stack[i].stack_pos

func get_held_order() -> FoodItem:
	if len(food_stack) > 0:
		return food_stack[0]
	else:
		return null

func holding_valid_order() -> bool:
	var order = get_held_order()
	if order == null: return false
	if is_instance_of(order, IceCream):
		if order.scoop_count() <= 0:
			return false
	return true
	
func food_in_stack(search : FoodItem) -> bool:
	for o in food_stack:
		if o.is_equal(search):
			return true
	return false

func _on_music_beat(_bar : bool):
	if not beat_initialized:
		beat_initialized = true
		anim.speed_scale = MusicManager.music_bpm / (60.0 * Utils.DEFAULT_ANIM_SPEED)
		anim.seek(0.0)
