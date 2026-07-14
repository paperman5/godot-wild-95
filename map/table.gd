@tool
class_name Table
extends StaticBody2D

var seated_customers : Array[Customer] = []
@export var seat_positions : Array[Node2D] = []
@export var seat_directions : Array[Vector2i] = []
@export var orientation : Utils.TableOrientation:
	get:
		return orientation
	set(value):
		orientation = value
		if is_instance_valid(spr):
			spr.texture.region = Utils.TableTextureRegions[value]
			spr.flip_h = value == Utils.TableOrientation.LEFT
@export var can_sit := true:
	set(value):
		can_sit = value
		if is_instance_valid(placemat_spr):
			placemat_spr.visible = value

@onready var spr = %Sprite2D as Sprite2D
@onready var placemat_spr = %Placemat as Sprite2D

func _ready() -> void:
	orientation = orientation
	can_sit = can_sit
	assert(len(seat_positions) == len(seat_directions))
	for seat in seat_positions:
		seated_customers.append(null)

func bump(_from_dir : Vector2):
	if not GameManager.player.holding_valid_order():
		return
	var test_order = GameManager.player.get_held_order()
	for customer in seated_customers:
		if is_instance_valid(customer) and customer.can_be_served() and customer.wants_food_type(test_order):
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
	if not can_sit:
		return true
	for customer in seated_customers:
		if not is_instance_valid(customer):
			return false
	return true

func _on_customer_left(_orders : Array[FoodItem], _bonus : bool, spot : int):
	seated_customers[spot] = null
