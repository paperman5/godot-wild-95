class_name Customer
extends Node2D

signal left_seat(orders : Array[FoodItem], bonus : bool)

var orig_orders : Array[FoodItem] = []
var orders_left : Array[FoodItem] = []
var bonus := false

@onready var anim := %AnimationPlayer as AnimationPlayer
@onready var order_backer := %Backer as Sprite2D
@onready var icecream_scene := preload("uid://cg80er3ff08wp")

func _ready() -> void:
	randomize_order()
	left_seat.connect(GameManager.level.customer_left)

func has_matching_order(order_to_check : FoodItem) -> bool:
	return find_matching_order(order_to_check) >= 0

func find_matching_order(order_to_check : FoodItem) -> int:
	for i in len(orders_left):
		if order_to_check.is_equal(orders_left[i]):
			return i
	return -1

func deliver_order(order : FoodItem):
	var order_i = find_matching_order(order)
	if order_i >= 0:
		orders_left.remove_at(order_i)
	if len(orders_left) == 0:
		start_eating()

func start_eating():
	left_seat.emit(orig_orders, bonus)
	queue_free()

func sit_direction(dir : Vector2):
	if dir.normalized().is_equal_approx(Vector2.UP):
		anim.play("idle_up")
	elif dir.normalized().is_equal_approx(Vector2.RIGHT):
		anim.play("idle_right")
	elif dir.normalized().is_equal_approx(Vector2.DOWN):
		anim.play("idle_down")
	elif dir.normalized().is_equal_approx(Vector2.LEFT):
		anim.play("idle_left")

func randomize_order():
	var icecream = icecream_scene.instantiate()
	order_backer.add_child(icecream)
	for i in range(icecream.max_flavors):
		icecream.add_flavor([Utils.IceCreamType.BooBerry, 
							Utils.IceCreamType.ShockALot, 
							Utils.IceCreamType.Vilenilla].pick_random())
	orig_orders = [icecream]
	orders_left = [icecream]
