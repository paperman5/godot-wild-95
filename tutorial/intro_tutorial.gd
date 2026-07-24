class_name IntroTutorial
extends TutorialScript

var tut_text := """This is Sabrina!
Move around using
[img]uid://48n42t1hvytc[/img][img]uid://dkvmx61w5gw20[/img]"""

var tut_text_2 := """Interact with things by bumping into them.
Grab a cup and start serving!"""

var tut_text_3 := """Serve customers by bumping the counter.
Pay close attention to what each one wants!"""

var tut_text_4 := """They aren't picky about the order of scoops.
[img height=64]uid://dhg0frv6gea8c[/img][font_size=48] = [/font_size][img height=64]uid://d4e5ukqgm74xs[/img]"""

var tut_text_5 := """Serving a customer quickly and
correctly will earn you bonus cash!"""

var tut_text_6 := """Correctly serving multiple
orders in quick succession will add
a combo multiplier!"""

var tut_text_7 := """You can stack up to 4 orders in
your hand! Orders are served
from the bottom first."""

var tut_text_7_5 := """Stack 'em high and serve 'em
fast to get a big combo!
[img width=48]uid://bg0806348ngcd[/img]"""

var tut_text_8 := """Try to get the highest score you can
before the time runs out!"""

var tut_text_9 := """Now that you know the basics,
let's try a full round..."""

var sabrina : Player

func show_tutorial():
	GameManager.level.seating_timer.paused = true
	
	# Movement tutorial
	sabrina = GameManager.player
	var text_1_pos := Utils.get_node_ui_position(sabrina, Vector2(48, -32))
	var text_2_pos := Utils.get_node_ui_position(sabrina, Vector2(0, 8))
	var ic_a := Utils.get_node_screen_position(GameManager.level.get_node("IceCreamGlassDispenser"), Vector2(0, -18))
	var ic_b := Utils.get_node_screen_position(GameManager.level.get_node("IceCreamDispenser4"), Vector2(0, -18))
	TutorialManager.pause()
	TutorialManager.highlight_node(sabrina, 64.0, Vector2.UP * 14)
	TutorialManager.clear_text()
	await TutorialManager.fade_in()
	TutorialManager.set_text(tut_text, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_1_pos)
	TutorialManager.start_acknowledge(1.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.clear_highlights()
	TutorialManager.highlight_slot(ic_a, ic_b, 36.0)
	TutorialManager.clear_text()
	TutorialManager.set_text(tut_text_2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_2_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.fade_out()
	await GameManager.get_tree().create_timer(0.1).timeout
	TutorialManager.unpause()
	
	await GameManager.get_tree().create_timer(2.0).timeout
	TutorialManager.clear_text()
	
	# Serving tutorial
	var target_table := GameManager.level.get_node("Counter2") as Table
	var target_customer := GameManager.level.create_customer()
	var icecream := preload("uid://cg80er3ff08wp").instantiate() as IceCream
	icecream.add_flavor(Utils.IceCreamType.BooBerry)
	icecream.add_flavor(Utils.IceCreamType.ShockALot)
	target_customer.set_orders([icecream])
	target_customer.served.connect(GameManager.level._on_customer_served)
	target_table.seat_customer_random_spot(target_customer)
	var target_order = target_customer.bubble_root
	var text_3_pos = Utils.get_node_ui_position(target_order, Vector2(40, -32))
	await GameManager.get_tree().create_timer(target_customer.think_time + 0.5).timeout
	TutorialManager.clear_highlights()
	TutorialManager.clear_text()
	TutorialManager.pause()
	TutorialManager.highlight_node(target_order, 52.0, Vector2.UP * 12)
	await TutorialManager.fade_in()
	TutorialManager.set_text(tut_text_3, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_3_pos)
	TutorialManager.start_acknowledge(1.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.clear_text()
	TutorialManager.set_text(tut_text_4, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_3_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.clear_text()
	TutorialManager.set_text(tut_text_5, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_3_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.fade_out()
	await GameManager.get_tree().create_timer(0.1).timeout
	TutorialManager.unpause()
	await target_customer.left_seat
	
	await GameManager.get_tree().create_timer(2.0).timeout
	TutorialManager.clear_text()
	
	# Combo tutorial
	target_table = GameManager.level.get_node("Counter2") as Table
	target_customer = GameManager.level.create_customer()
	icecream = preload("uid://cg80er3ff08wp").instantiate() as IceCream
	icecream.add_flavor(Utils.IceCreamType.Vilenilla)
	target_customer.set_orders([icecream])
	target_customer.served.connect(GameManager.level._on_customer_served)
	var target_table_2 := GameManager.level.get_node("Counter3") as Table
	var target_customer_2 := GameManager.level.create_customer()
	icecream = preload("uid://cg80er3ff08wp").instantiate() as IceCream
	icecream.add_flavor(Utils.IceCreamType.BooBerry)
	icecream.add_flavor(Utils.IceCreamType.Vilenilla)
	icecream.add_flavor(Utils.IceCreamType.ShockALot)
	target_customer_2.set_orders([icecream])
	target_customer_2.served.connect(GameManager.level._on_customer_served)
	target_table.seat_customer_random_spot(target_customer)
	target_table_2.seat_customer_random_spot(target_customer_2)
	target_order = target_customer.bubble_root
	var target_order_2 = target_customer_2.bubble_root
	var text_6_pos = text_3_pos + Vector2(96, 0)
	await GameManager.get_tree().create_timer(target_customer.think_time + 0.5).timeout
	TutorialManager.clear_highlights()
	TutorialManager.clear_text()
	TutorialManager.pause()
	TutorialManager.highlight_nodes([target_order, target_order_2], [52.0, 52.0], [Vector2.UP * 12, Vector2.UP * 12])
	await TutorialManager.fade_in()
	TutorialManager.set_text(tut_text_6, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_6_pos)
	TutorialManager.start_acknowledge(1.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.set_text(tut_text_7, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_6_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.set_text(tut_text_7_5, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_6_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.fade_out()
	await GameManager.get_tree().create_timer(0.1).timeout
	TutorialManager.unpause()
	
	await target_customer.left_seat
	if is_instance_valid(target_customer_2):
		await target_customer_2.left_seat
	
	await GameManager.get_tree().create_timer(2.0).timeout
	
	# Highlight score & timer
	var score_pos := Utils.get_node_screen_position(GameManager.game_ui.score_display, Vector2(64, 16))
	var timer_pos := Utils.get_node_screen_position(GameManager.game_ui.timer_ui, Vector2(32, 16))
	var text_8_pos = Utils.get_node_ui_position(GameManager.game_ui.score_display) + Vector2(190,250)
	TutorialManager.clear_highlights()
	TutorialManager.clear_text()
	TutorialManager.pause()
	TutorialManager.highlight_slot(score_pos, timer_pos, 48)
	await TutorialManager.fade_in()
	TutorialManager.set_text(tut_text_8, HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT, text_8_pos)
	TutorialManager.start_acknowledge(1.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.clear_highlights()
	TutorialManager.clear_text()
	var text_9_pos := TutorialManager.root.get_global_rect().get_center() as Vector2
	TutorialManager.set_text(tut_text_9, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER, text_9_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.fade_out()
	await GameManager.get_tree().create_timer(0.1).timeout
	await TutorialManager.anim.animation_finished
	await GameManager.get_tree().create_timer(1.0).timeout
	
	GameManager.save_won("level_1")
	GameManager.change_scene("level_1")

pass
