@tool
class_name Table
extends StaticBody2D

var seated_customers : Array[Customer] = []
var seat_positions : Array[Node2D] = []
var seat_directions : Array[Vector2i] = []
@export var orientation := Utils.TableOrientation.HOR_CENTER:
	get:
		return orientation
	set(value):
		orientation = value
		_set_orientation(value)
		_set_placemat(can_sit)
@export var can_sit := true:
	set(value):
		can_sit = value
		_set_orientation(orientation)
		_set_placemat(value)

@onready var spr = %Sprite2D as Sprite2D
@onready var placemat_spr_h = %PlacematH as Sprite2D
@onready var placemat_spr_v = %PlacematV as Sprite2D
@onready var corner := %Corner as Sprite2D
@onready var audio: AudioStreamPlayer2D = %AudioStreamPlayer2D

func _ready() -> void:
	orientation = orientation
	can_sit = can_sit
	assert(len(seat_positions) == len(seat_directions))
	for seat in seat_positions:
		seated_customers.append(null)

func bump(_from_dir : Vector2) -> bool:
	if not GameManager.player.holding_valid_order():
		return false
	var test_order = GameManager.player.get_held_order()
	for customer in seated_customers:
		if is_instance_valid(customer) and customer.can_be_served() and customer.wants_food_type(test_order):
			customer.deliver_order(test_order)
			GameManager.player.pop_food_stack()
			return true
	return false

func seat_customer_random_spot(customer : Customer):
	var seat = randi_range(0, len(seat_positions)-1)
	while seated_customers[seat] == null and not table_is_full:
		randi_range(0, len(seat_positions)-1)
	seat_customer(customer, seat)

func seat_customer(customer : Customer, spot : int):
	if customer.get_parent() == null:
		GameManager.level.add_child(customer)
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

func _on_customer_left(_orders : Array[FoodItem], spot : int):
	seated_customers[spot] = null

func _set_orientation(dir : Utils.TableOrientation):
	if is_instance_valid(spr):
		var region := Utils.TableTextureRegions[dir] as Rect2
		if is_equal_approx(region.size.y, 32.0):
			spr.offset.y = 0
		else:
			spr.offset.y = -16
		spr.texture.region = region
		spr.flip_h = should_flip_texture(dir)
		placemat_spr_v.flip_h = spr.flip_h
		corner.flip_h = spr.flip_h
		corner.visible = dir in [Utils.TableOrientation.CORNER_LEFT, 
								Utils.TableOrientation.CORNER_RIGHT]
		seat_positions = []
		seat_directions = []
		if can_sit:
			match orientation:
				Utils.TableOrientation.HOR_LEFT, Utils.TableOrientation.HOR_CENTER, Utils.TableOrientation.HOR_RIGHT:
					seat_positions.append(%SeatB)
					seat_directions.append(Vector2i.UP)
				Utils.TableOrientation.VERT_LEFT:
					seat_positions.append(%SeatL)
					seat_directions.append(Vector2i.RIGHT)
				Utils.TableOrientation.VERT_RIGHT:
					seat_positions.append(%SeatR)
					seat_directions.append(Vector2i.LEFT)

func _set_placemat(enabled : bool):
	if is_instance_valid(placemat_spr_h):
		placemat_spr_h.visible = orientation in [Utils.TableOrientation.HOR_LEFT,
											Utils.TableOrientation.HOR_CENTER,
											Utils.TableOrientation.HOR_RIGHT] \
								and enabled
	if is_instance_valid(placemat_spr_v):
		placemat_spr_v.visible = orientation in [Utils.TableOrientation.VERT_LEFT,
											Utils.TableOrientation.VERT_RIGHT] \
								and enabled

static func should_flip_texture(dir : Utils.TableOrientation) -> bool:
	return dir in [Utils.TableOrientation.HOR_LEFT,
					Utils.TableOrientation.VERT_LEFT,
					Utils.TableOrientation.CORNER_LEFT]
