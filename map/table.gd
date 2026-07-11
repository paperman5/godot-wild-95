class_name Table
extends StaticBody2D

var seated_customers : Array[Customer] = []
@export var seat_positions : Array[Node2D] = []
@export var seat_directions : Array[Vector2i] = []

func _ready() -> void:
	assert(len(seat_positions) == len(seat_directions))
	for seat in seat_positions:
		seated_customers.append(null)

func bump(_from_dir : Vector2):
	var test_order = GameManager.player.get_held_order()
	if not is_instance_valid(test_order):
		return
	for customer in seated_customers:
		if is_instance_valid(customer) and customer.has_matching_order(test_order):
			customer.deliver_order(test_order)
			GameManager.player.pop_food_stack()

func seat_customer_random_spot(customer : Customer):
	var seat = randi_range(0, len(seat_positions)-1)
	while seated_customers[seat] == null and not table_is_full:
		randi_range(0, len(seat_positions)-1)
	seat_customer(customer, seat)

func seat_customer(customer : Customer, spot : int):
	seated_customers[spot] = customer
	customer.global_position = seat_positions[spot].global_position
	customer.sit_direction(Vector2(seat_directions[spot]).normalized())
	customer.left_seat.connect(_on_customer_left.bind(spot), CONNECT_ONE_SHOT)

func table_is_full() -> bool:
	for customer in seated_customers:
		if not is_instance_valid(customer):
			return false
	return true

func _on_customer_left(_orders : Array[FoodItem], _bonus : bool, spot : int):
	seated_customers[spot] = null
