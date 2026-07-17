class_name Level
extends Node2D

signal time_up
signal combo_cleared
signal customer_seated(customer : Customer)

var tables : Array[Table] = []
var customer_scene = preload("uid://uddj0n5ca5xs")
@export var customer_seating_timer := 3.0
@export var time_limit := 100.0
@export var timer_increments := 1.0
@export var ice_cream_score := 5
@export var food_score := 10
@export var ice_cream_prompt_bonus := 3
@export var food_prompt_bonus := 3
@export var failed_order_multiplier := 0.5
@export var win_threshold := 50
@export var combo_cooldown := 2.0
@export var combo_refresh_on_success := true
@export var combo_bonus := 0.25
@export var max_icecream_scoops := 3
@export var customer_icecream_chance := 1.0
@export var customer_food_chance := 0.0
@export var next_level := "level_1"
@export var music : MultiBPMAudioStream
# TODO: Stats?

var score := 0
var combo := 0
var combo_points_buffer := 0.0
var paused := true
var game_started := false

@onready var level_timer := %LevelTimer as Timer
@onready var combo_timer := %ComboTimer as Timer
@onready var ticker_timer := %TimerTicker as Timer
@onready var seating_timer := %SeatingTimer as Timer
@onready var ui := %IngameUI as GameUI
@onready var cam := get_node("Camera2D") as Camera2D

func _ready() -> void:
	GameManager.level = self
	var all_tables = get_tree().get_nodes_in_group("tables")
	for t in all_tables:
		if is_instance_of(t, Table):
			tables.append(t)
	
	MusicManager.start_music(music)
	
	ui.set_max_time(time_limit)
	ui.set_time_remaining(time_limit)
	level_timer.start(time_limit)
	seating_timer.start(customer_seating_timer)
	ticker_timer.start(timer_increments)
	pause()
	
	level_timer.timeout.connect(_on_time_up)
	combo_timer.timeout.connect(_on_combo_timer_timeout)
	seating_timer.timeout.connect(_on_seating_timer_timeout)
	ticker_timer.timeout.connect(_on_ticker_timer_timeout)
	
	customer_seated.connect(TutorialManager._on_customer_seated)
	
	GameManager.menus.show_begin()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not paused and game_started:
			pause(true)
		elif paused and game_started:
			unpause(true)

func _on_seating_timer_timeout():
	seat_random_table()

func _on_ticker_timer_timeout():
	ui.set_time_remaining(level_timer.time_left)

func create_customer() -> Customer:
	var new_customer := customer_scene.instantiate() as Customer
	new_customer.customer_type = [Customer.CustomerType.Nightwalker,
								Customer.CustomerType.Mothman,
								Customer.CustomerType.Yeti,
								Customer.CustomerType.Goo].pick_random()
	new_customer.icecream_order_chance = customer_icecream_chance
	new_customer.food_order_chance = customer_food_chance
	new_customer.served.connect(_on_customer_served)
	return new_customer

func seat_random_table():
	if not any_table_is_open():
		return
	var table = tables.pick_random()
	while table.table_is_full():
		table = tables.pick_random()
	
	var new_customer := create_customer()
	add_child(new_customer)
	table.seat_customer_random_spot(new_customer)
	customer_seated.emit(new_customer)

func any_table_is_open() -> bool:
	for table in tables:
		if not table.table_is_full():
			return true
	return false

func _on_customer_served(order : FoodItem, matched : bool, prompt : bool):
	combo_points_buffer += get_score_for_order(order, matched, prompt)
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
	GameManager.game_ui.set_combo(0, 1.0)
	GameManager.game_ui.set_money(score)

func _on_time_up():
	pause()
	if score >= win_threshold:
		win_game()
	else:
		lose_game()

func pause(show_menu : bool = false):
	for t in get_tree().get_nodes_in_group("timers"):
		t.process_mode = Node.PROCESS_MODE_DISABLED
	if show_menu:
		GameManager.menus.show_pause()
	paused = true
	MusicManager.set_music_lofi(true)

func unpause(clear_menu : bool = false):
	for t in get_tree().get_nodes_in_group("timers"):
		t.process_mode = Node.PROCESS_MODE_INHERIT
	if clear_menu:
		GameManager.menus.hide_all()
	if not game_started:
		game_started = true
	paused = false
	MusicManager.set_music_lofi(false)

func lose_game():
	pause()
	GameManager.menus.show_lose()

func win_game():
	pause()
	GameManager.menus.show_win()

func get_order_base_points(order : FoodItem) -> float:
	if is_instance_of(order, IceCream):
		return float(ice_cream_score)
	elif is_instance_of(order, CookedFood):
		return float(food_score)
	return 0.0

func get_score_for_order(order : FoodItem, matched : bool, prompt : bool) -> int:
	var s := float(ice_cream_score if is_instance_of(order, IceCream) else food_score)
	if prompt and matched:
		s += ice_cream_prompt_bonus if is_instance_of(order, IceCream) else food_prompt_bonus
	if not matched:
		s *= failed_order_multiplier
	return roundi(s)
		
