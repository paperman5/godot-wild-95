extends TutorialScript

var tut_text := """This is Sabrina!
Move around using
[img]uid://48n42t1hvytc[/img][img]uid://dkvmx61w5gw20[/img]"""

var tut_text_2 := """Interact with things by
bumping into them.
Grab a cup and start serving!"""

var sabrina : Player

func show_tutorial():
	sabrina = GameManager.player
	var sabrina_screen_pos := Utils.get_node_ui_position(sabrina, Vector2(48, -32))
	var sabrina_pos_2 := Utils.get_node_ui_position(sabrina, Vector2(0, 8))
	var ic_a := Utils.get_node_screen_position(GameManager.level.get_node("IceCreamGlassDispenser"), Vector2(0, -15))
	var ic_b := Utils.get_node_screen_position(GameManager.level.get_node("IceCreamDispenser4"), Vector2(0, -15))
	TutorialManager.pause()
	TutorialManager.highlight_nodes([sabrina], [32.0], [Vector2.UP * 14])
	await TutorialManager.fade_in()
	TutorialManager.set_text(tut_text, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, sabrina_screen_pos)
	TutorialManager.start_acknowledge(1.0)
	var last_action = await TutorialManager.tutorial_acknowledged
	TutorialManager.clear_highlights()
	TutorialManager.highlight_slot(ic_a, ic_b, 20.0)
	TutorialManager.set_text(tut_text_2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, sabrina_pos_2)
	TutorialManager.start_acknowledge(0.0)
	last_action = await TutorialManager.tutorial_acknowledged
	TutorialManager.unpause()
	Input.action_press(last_action)
	TutorialManager.fade_out()
