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

signal left_seat(orders : Array[FoodItem], bonus : bool)
signal served(order : FoodItem, matched : bool)

var orig_orders : Array[FoodItem] = []
var orders_left : Array[FoodItem] = []
var orders_given : Array[FoodItem] = []
var thinking := true
var eating := false
var bonus := true

@export var customer_type := CustomerType.Nightwalker:
	set(value):
		customer_type = value
		if is_instance_valid(anim):
			sit_direction(Vector2.DOWN)
@export var eat_wait_time := 1.0
@export var think_time := 2.0
@export var prompt_bonus_time := 5.0

@onready var spr := %Sprite2D as Sprite2D
@onready var anim := %AnimationPlayer as AnimationPlayer
@onready var order_bubble := %OrderBubble as Node2D
@onready var thinking_bubble := %ThinkingBubble as AnimatedSprite2D
@onready var bubble_root := %BubbleRoot as Node2D
@onready var bubble_ninepatch := %BubbleNinePatch as NinePatchRect
@onready var bubble_tail := %BubbleTail as Sprite2D
@onready var icecream_scene := preload("uid://cg80er3ff08wp")
@onready var eat_wait_timer := %EatWaitTimer as Timer
@onready var thinking_timer := %ThinkingTimer as Timer
@onready var bonus_timer := %BonusTimer as Timer

func _ready() -> void:
	if not Engine.is_editor_hint():
		left_seat.connect(GameManager.level.customer_left)
		randomize_order()
		thinking_bubble.show()
		bubble_root.hide()
		anim.speed_scale = 0.5
		thinking_timer.start(think_time)

func has_matching_order(order_to_check : FoodItem) -> bool:
	return find_matching_order(order_to_check) >= 0

func find_matching_order(order_to_check : FoodItem) -> int:
	for i in len(orders_left):
		if order_to_check.is_equal(orders_left[i]):
			return i
	return -1

func deliver_order(order : FoodItem):
	if len(orders_left) <= 0:
		return
	var order_i = find_matching_order(order)
	served.emit(order, order_i >= 0)
	orders_given.append(order)
	orders_left.remove_at(order_i if order_i >= 0 else 0)
	if len(orders_left) <= 0:
		# TODO: Check if all orders are correct
		start_eating(true)
	else:
		bubble_fit_orders()

func start_eating(order_matched : bool):
	order_bubble.hide()
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
	anim.play(anim_library + "/" + "RESET")
	anim.seek(0.0, true)
	if not Engine.is_editor_hint():
		anim.play(anim_key)
	else:
		anim.play(anim_key)
		anim.seek(0.0, true)
		anim.stop()

func randomize_order():
	var icecream := icecream_scene.instantiate() as IceCream
	icecream.max_flavors = GameManager.level.max_icecream_scoops
	var scoops = randi_range(1, icecream.max_flavors)
	bubble_root.add_child(icecream)
	for i in range(scoops):
		icecream.add_flavor([Utils.IceCreamType.BooBerry, 
							Utils.IceCreamType.ShockALot, 
							Utils.IceCreamType.Vilenilla].pick_random())
	orig_orders = [icecream]
	orders_left = [icecream]
	bubble_fit_orders()

func bubble_fit_orders():
	const margin_side := 3
	const margin_top := 3
	const margin_bot := 4
	const order_spacing := 3
	const tail_x_offset := 5
	var orders_height := 0.0
	var orders_width := 0.0
	for order in orders_left:
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
	left_seat.emit(orig_orders, bonus)
	queue_free()

func _on_thinking_timer_timeout():
	thinking = false
	thinking_bubble.hide()
	bubble_root.show()
	anim.speed_scale = 1.0
	anim.seek(0.0)

func _on_bonus_timer_timeout():
	bonus = false

func can_be_served() -> bool:
	return len(orders_left) > 0 and not thinking and not eating
