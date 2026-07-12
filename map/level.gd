class_name Level
extends Node2D

signal time_up
signal combo_cleared

var tables : Array[Table] = []
var customer_scene = preload("uid://uddj0n5ca5xs")
@export var customer_seating_timer := 3.0
@export var time_limit := 100.0
@export var timer_progress_bar : TextureProgressBar
@export var ice_cream_score := 5
@export var food_score := 10
@export var failed_order_multiplier := 0.5
@export var win_threshold := 50
@export var combo_cooldown := 2.0
@export var combo_refresh_on_success := true
@export var combo_bonus := 0.25
# TODO: Stats?

var score := 0
var combo := 0
var combo_points_buffer := 0.0
var paused := false

@onready var combo_timer := %ComboTimer as Timer

func _ready() -> void:
	assert(timer_progress_bar != null)
	GameManager.level = self
	timer_progress_bar.max_value = time_limit
	timer_progress_bar.value = 0.0
	var all_tables = get_tree().get_nodes_in_group("tables")
	for t in all_tables:
		if is_instance_of(t, Table):
			tables.append(t)
	_create_seating_timer()
	time_up.connect(_on_time_up)
	combo_timer.timeout.connect(_on_combo_timer_timeout)

func _process(delta: float) -> void:
	if paused:
		return
	timer_progress_bar.value += delta
	if is_equal_approx(timer_progress_bar.value, timer_progress_bar.max_value):
		time_up.emit()

func _create_seating_timer():
	var t = get_tree().create_timer(customer_seating_timer)
	t.timeout.connect(_on_timer_timeout, CONNECT_ONE_SHOT)

func _on_timer_timeout():
	seat_random_table()
	_create_seating_timer.call_deferred()

func seat_random_table():
	if not any_table_is_open():
		return
	var table = tables.pick_random()
	while table.table_is_full():
		table = tables.pick_random()
	
	var new_customer := customer_scene.instantiate() as Customer
	add_child(new_customer)
	table.seat_customer_random_spot(new_customer)
	new_customer.served.connect(_on_customer_served)

func any_table_is_open() -> bool:
	for table in tables:
		if not table.table_is_full():
			return true
	return false

func customer_left(orders : Array[FoodItem], bonus : bool):
	pass
	#var tally := 0.0
	#for i in range(len(orders)):
		#tally += ice_cream_score if is_instance_of(orders[i], IceCream) else food_score
	#tally *= pow(order_count_multiplier, len(orders)-1)
	#score += roundi(tally)
	#GameManager.game_ui.set_money(score)

func _on_customer_served(order : FoodItem, matched : bool):
	combo_points_buffer += get_order_base_points(order) * (1 if matched else failed_order_multiplier)
	if matched:
		combo += 1
		if combo_refresh_on_success:
			combo_timer.start(combo_cooldown)
	else:
		combo_timer.stop()
		combo_timer.timeout.emit()
	GameManager.game_ui.set_combo(roundi(combo_points_buffer), 1+combo*combo_bonus)

func _on_combo_timer_timeout():
	score += round(combo_points_buffer * (1 + combo * combo_bonus))
	combo = 0
	combo_points_buffer = 0.0
	combo_cleared.emit()
	GameManager.game_ui.set_combo(0, 0.0)
	GameManager.game_ui.set_money(score)

func _on_time_up():
	paused = true
	get_tree().paused = true
	if score >= win_threshold:
		win_game()
	else:
		lose_game()

func lose_game():
	GameManager.menus.show_lose()

func win_game():
	GameManager.menus.show_win()

func get_order_base_points(order : FoodItem) -> float:
	if is_instance_of(order, IceCream):
		return float(ice_cream_score)
	elif is_instance_of(order, CookedFood):
		return float(food_score)
	return 0.0
