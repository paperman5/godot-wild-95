@tool
class_name Customer
extends Node2D

enum CustomerType {
	Nightwalker,
	Alien,
	Goo,
	Yeti,
	Mothman
}
const anim_library_keys = {
	CustomerType.Nightwalker : "nightwalker",
	CustomerType.Alien : "alien",
	CustomerType.Goo : "goo",
	CustomerType.Yeti : "yeti",
	CustomerType.Mothman : "mothman",
}

signal left_seat(orders : Array[FoodItem])
signal served(order : FoodItem, matched : bool, prompt : bool)

var orig_orders : Array[FoodItem] = []
var orders_left : Array[FoodItem] = []
var orders_given : Array[FoodItem] = []
var thinking := true
var eating := false
var prompt := true
var failed_order := false

@export var customer_type := CustomerType.Nightwalker:
	set(value):
		customer_type = value
		#if is_instance_valid(anim):
			#sit_direction(Vector2.DOWN)
@export var eat_wait_time := 1.0
@export var think_time := 2.0
@export var prompt_bonus_time := 5.0
@export var icecream_order_chance := 1.0
@export var food_order_chance := 0.25

@onready var spr := %Sprite2D as Sprite2D
@onready var anim := %AnimationPlayer as AnimationPlayer
@onready var order_bubble := %OrderBubble as Node2D
@onready var thinking_bubble := %ThinkingBubble as AnimatedSprite2D
@onready var bubble_root := %BubbleRoot as Node2D
@onready var bubble_ninepatch := %BubbleNinePatch as NinePatchRect
@onready var bubble_tail := %BubbleTail as Sprite2D
@onready var icecream_scene := preload("uid://cg80er3ff08wp")
@onready var food_scene := preload("uid://b6duh0virt7sy")
@onready var eat_wait_timer := %EatWaitTimer as Timer
@onready var thinking_timer := %ThinkingTimer as Timer
@onready var prompt_timer := %PromptTimer as Timer
@onready var music_sync := %MusicSyncComponent as MusicSyncComponent
@onready var combo_root := %ComboRoot as Node2D
@onready var combo_text := %ComboText as ComboText
@onready var patience_progress := %PatienceProgress as TextureProgressBar

func _ready() -> void:
	if not Engine.is_editor_hint():
		customer_type = customer_type
		randomize_order()
		thinking_bubble.show()
		bubble_root.hide()
		combo_text.text = ""
		music_sync.advance_every_n_beats = 4
		thinking_timer.start(think_time)
		music_sync.starting_animation = anim_library_keys[customer_type] + "/idle_down"
		music_sync.start_sync()
		patience_progress.tint_progress = Utils.colors["matched"]

func _process(delta: float) -> void:
	if not eating and not thinking:
		patience_progress.value = prompt_timer.time_left / prompt_bonus_time

func has_matching_order(order_to_check : FoodItem) -> bool:
	return find_matching_order(order_to_check) >= 0

func find_matching_order(order_to_check : FoodItem) -> int:
	for i in len(orders_left):
		if order_to_check.is_equal(orders_left[i]):
			return i
	return -1

func wants_icecream() -> bool:
	for order in orders_left:
		if is_instance_of(order, IceCream):
			return true
	return false

func wants_cooked_food() -> bool:
	for order in orders_left:
		if is_instance_of(order, CookedFood):
			return true
	return false

func wants_food_type(order : FoodItem) -> bool:
	if is_instance_of(order, IceCream) and wants_icecream():
		return true
	elif is_instance_of(order, CookedFood) and wants_cooked_food():
		return true
	return false

func deliver_order(order : FoodItem):
	if len(orders_left) <= 0:
		return
	var order_i = find_matching_order(order)
	var matched = order_i >= 0
	failed_order = failed_order or (not matched)
	combo_text.failed_order = failed_order
	served.emit(order, matched, prompt)
	orders_given.append(order)
	if not matched:
		combo_text.shown_bonus = 1.0
		if is_instance_of(order, IceCream) and wants_icecream():
			for oi in range(len(orders_left)):
				if is_instance_of(orders_left[oi], IceCream):
					combo_text.shown_price += GameManager.level.get_score_for_order(orders_left[oi], false, false)
					orders_left[oi].hide()
					orders_left.remove_at(oi)
					break
		elif is_instance_of(order, CookedFood) and wants_cooked_food():
			for oi in range(len(orders_left)):
				if is_instance_of(orders_left[oi], CookedFood):
					combo_text.shown_price += GameManager.level.get_score_for_order(orders_left[oi], false, false)
					orders_left[oi].hide()
					orders_left.remove_at(oi)
					break
	else:
		combo_text.shown_price += GameManager.level.get_score_for_order(orders_left[order_i], true, prompt)
		combo_text.shown_bonus += GameManager.level.combo_bonus
		orders_left[order_i].hide()
		orders_left.remove_at(order_i)
	if len(orders_left) <= 0:
		start_eating(not failed_order)
	else:
		bubble_fit_orders()

func start_eating(_order_matched : bool):
	bubble_root.hide()
	thinking_bubble.hide()
	music_sync.advance_every_n_beats = 1
	eat_wait_timer.start(eat_wait_time)
	eating = true
	# TODO: Play correct animation if order is matched or not

func sit_direction(dir : Vector2):
	var anim_dir = ""
	dir = dir.normalized()
	if dir.is_equal_approx(Vector2.LEFT):
		anim_dir = "idle_side"
		spr.flip_h = true
	elif dir.is_equal_approx(Vector2.RIGHT):
		anim_dir = "idle_side"
		spr.flip_h = false
	else:
		anim_dir = "idle_down"
	var anim_library = anim_library_keys[customer_type]
	var anim_key = anim_library + "/" + anim_dir
	anim.current_animation = anim_library + "/" + "RESET"
	anim.seek(0.0, true)
	anim.current_animation = anim_key
	anim.seek(0.0, true)
	anim.pause()
	#anim.play(anim_library + "/" + "RESET")
	#anim.seek(0.0, true)
	#if not Engine.is_editor_hint():
		#anim.play(anim_key)
	#else:
		#anim.play(anim_key)
		#anim.seek(0.0, true)
		#anim.stop()

func randomize_order():
	var order_food := randf() <= food_order_chance
	if order_food:
		var food = food_scene.instantiate() as CookedFood
		food.food_type = [Utils.FoodType.MonsterMashBurger, 
							Utils.FoodType.Werewaffles].pick_random()
		food.icon = true
		bubble_root.add_child(food)
		orig_orders.append(food)
		orders_left.append(food)
	var order_icecream := randf() <= icecream_order_chance
	if order_icecream:
		var icecream := icecream_scene.instantiate() as IceCream
		icecream.max_flavors = GameManager.level.max_icecream_scoops
		var scoops = randi_range(1, icecream.max_flavors)
		bubble_root.add_child(icecream)
		for i in range(scoops):
			icecream.add_flavor([Utils.IceCreamType.BooBerry, 
								Utils.IceCreamType.ShockALot, 
								Utils.IceCreamType.Vilenilla].pick_random())
		orig_orders.append(icecream)
		orders_left.append(icecream)
	bubble_fit_orders()

func bubble_fit_orders():
	const margin_side := 3
	const margin_top := 3
	const margin_bot := 4
	const order_spacing := 4
	const tail_x_offset := 5
	var orders_height := 0.0
	var orders_width := 0.0
	for order in orders_left:
		order.position.y = -orders_height
		orders_height += abs(order.stack_pos.position.y)
		orders_height += order_spacing
		orders_width = maxf(orders_width, 12.0 if order is IceCream else 16.0)
	orders_height = maxf(orders_height - order_spacing, 0.0)
	
	bubble_ninepatch.offset_left = -(orders_width/2 + margin_side)
	bubble_ninepatch.offset_right = orders_width/2 + margin_side
	bubble_ninepatch.offset_top = -(orders_height + margin_top)
	bubble_ninepatch.offset_bottom = margin_bot
	bubble_tail.offset = Vector2(bubble_ninepatch.offset_left + tail_x_offset, margin_bot)

func finished_eating():
	left_seat.emit(orig_orders)
	combo_text.final = true
	var prev_pos := combo_root.global_position
	combo_root.get_parent().remove_child(combo_root)
	GameManager.level.add_child(combo_root)
	combo_root.global_position = prev_pos
	queue_free()

func _on_thinking_timer_timeout():
	thinking = false
	thinking_bubble.hide()
	bubble_root.show()
	music_sync.advance_every_n_beats = 2
	prompt_timer.start(prompt_bonus_time)

func can_be_served() -> bool:
	return len(orders_left) > 0 and not thinking and not eating


func _on_prompt_timer_timeout() -> void:
	prompt = false
