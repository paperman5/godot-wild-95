class_name ServingTutorial
extends TutorialScript

var tut_text := """Serve customers by bumping the counter.
Pay close attention to what each one wants!"""

var tut_text_2 := """Serving a customer quickly and
correctly will earn you bonus cash!"""

func show_tutorial():
	var target_customer : Customer
	for c in GameManager.level.get_children():
		if is_instance_of(c, Customer):
			target_customer = c
			break
	var target_order = target_customer.bubble_root
	var text_pos = Utils.get_node_ui_position(target_order, Vector2(40, -32))
	await GameManager.get_tree().create_timer(target_customer.think_time + 0.5).timeout
	TutorialManager.pause()
	TutorialManager.highlight_node(target_order, 24.0, Vector2.UP * 12)
	await TutorialManager.fade_in()
	TutorialManager.set_text(tut_text, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_pos)
	TutorialManager.start_acknowledge(1.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.set_text(tut_text_2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, text_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.unpause()
	TutorialManager.fade_out()
