class_name Level
extends Node2D

var tables : Array[Table] = []
var customer_scene = preload("uid://uddj0n5ca5xs")
@export var customer_seating_timer := 3.0

func _ready() -> void:
	var all_tables = get_tree().get_nodes_in_group("tables")
	for t in all_tables:
		if is_instance_of(t, Table):
			tables.append(t)
	_create_seating_timer()

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
