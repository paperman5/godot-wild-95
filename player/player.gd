class_name Player
extends Node2D

signal held_item_changed(new : FoodItem)

const TILE_SIZE = 32

@export var tile_move_speed := 0.1
@export var move_hold_cooldown := 0.15
@export var max_food_stack := 4
@export var empty_bump_sfx : AudioStream

@onready var spr := %Sprite2D as Sprite2D
@onready var anim := %AnimationPlayer as AnimationPlayer
@onready var hand := %Hand as Marker2D
@onready var audio: AudioStreamPlayer2D = %AudioStreamPlayer2D

var move_tween : Tween
var true_pos := Vector2.ZERO
var moving := false
var can_hold_move := true

var food_stack : Array[FoodItem] = []

func _ready() -> void:
	GameManager.player = self
	true_pos = position

func _physics_process(_delta: float) -> void:
	if GameManager.level.paused:
		return
	if moving:
		moving = false
		return
	
	var move_dir := Vector2.ZERO
	var prev_anim_time := anim.current_animation_position
	if Input.is_action_just_pressed("move_down") or \
			(Input.is_action_pressed("move_down") and can_hold_move):
		move_dir = Vector2.DOWN
		anim.current_animation = "walk_down"
		anim.seek(prev_anim_time)
	elif Input.is_action_just_pressed("move_up") or \
			(Input.is_action_pressed("move_up") and can_hold_move):
		move_dir = Vector2.UP
		anim.current_animation = "walk_up"
		anim.seek(prev_anim_time)
	elif Input.is_action_just_pressed("move_left") or \
			(Input.is_action_pressed("move_left") and can_hold_move):
		move_dir = Vector2.LEFT
		anim.current_animation = "walk_left"
		anim.seek(prev_anim_time)
	elif Input.is_action_just_pressed("move_right") or \
			(Input.is_action_pressed("move_right") and can_hold_move):
		move_dir = Vector2.RIGHT
		anim.current_animation = "walk_right"
		anim.seek(prev_anim_time)
	
	if not move_dir.is_zero_approx():
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = true_pos + move_dir * TILE_SIZE
		var result = space_state.intersect_point(query, 1)
		if result:
			var colliding_obj := result[0]['collider'] as Node2D
			if colliding_obj.has_method("bump"):
				var success = colliding_obj.bump(move_dir)
				if not success:
					audio.stream = empty_bump_sfx
					audio.play()
			_create_move_tween(move_dir, true)
		else:
			true_pos += move_dir * TILE_SIZE
			_create_move_tween(move_dir, false)

func _create_move_tween(dir : Vector2, bump : bool):
	if move_tween != null:
		move_tween.kill()
	
	moving = true
	can_hold_move = false
	var move_time := tile_move_speed * Engine.time_scale
	move_tween = create_tween().set_parallel(true)
	if not bump:
		move_tween.tween_property(self, "position", true_pos, move_time)
	else:
		move_tween.tween_property(self, "position", true_pos + TILE_SIZE*dir/2, move_time/2)
		move_tween.chain().tween_property(self, "position", true_pos, move_time/2)
	if GameManager.hold_to_move:
		move_tween.tween_interval(move_hold_cooldown * Engine.time_scale)
		move_tween.chain().tween_callback(func(): can_hold_move = true)
	
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
		var icecream := preload("uid://cg80er3ff08wp").instantiate() as IceCream
		icecream.set_symbols_visible(false)
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
	
func pop_food_stack() -> bool:
	var food = food_stack.pop_front()
	_restack_food()
	held_item_changed.emit(get_held_order())
	if food != null:
		food.queue_free()
		return true
	return false

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
