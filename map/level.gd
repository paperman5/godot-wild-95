class_name Level
extends Node2D

signal time_up

var tables : Array[Table] = []
var customer_scene = preload("uid://uddj0n5ca5xs")
@export var customer_seating_timer := 3.0
@export var time_limit := 100.0
@export var timer_progress_bar : TextureProgressBar
@export var ice_cream_score := 5
@export var food_score := 10
@export var order_count_multiplier := 1.2
@export var win_threshold := 50

var score := 0
var paused := false

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
	
	var new_customer = customer_scene.instantiate()
	add_child(new_customer)
	table.seat_customer_random_spot(new_customer)

func any_table_is_open() -> bool:
	for table in tables:
		if not table.table_is_full():
			return true
	return false

func customer_left(orders : Array[FoodItem], bonus : bool):
	var tally := 0.0
	for i in range(len(orders)):
		tally += ice_cream_score if is_instance_of(orders[i], IceCream) else food_score
	tally *= pow(order_count_multiplier, len(orders)-1)
	score += roundi(tally)
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
