class_name FoodTutorial
extends TutorialScript

var tut_text := """Marvy is here to cook!
Meals are worth more but take some time to make."""

var tut_text_2 := """Bump into a meal to start cooking,
and bump it again when it's done to pick it up."""

func show_tutorial():
	var ic_a := Utils.get_node_screen_position(GameManager.level.get_node("Marvy/FoodDispenser"), Vector2(0, -15))
	var ic_b := Utils.get_node_screen_position(GameManager.level.get_node("Marvy/FoodDispenser2"), Vector2(0, -15))
	var text_1_pos = ic_a + Vector2.DOWN*220
	TutorialManager.pause()
	TutorialManager.clear_highlights()
	TutorialManager.clear_text()
	TutorialManager.highlight_slot(ic_a, ic_b, 20.0)
	TutorialManager.highlight_node(GameManager.level.get_node("Marvy"), 30.0, Vector2(0, -42))
	await TutorialManager.fade_in()
	TutorialManager.set_text(tut_text, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER, text_1_pos)
	TutorialManager.start_acknowledge(1.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.set_text(tut_text_2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER, text_1_pos)
	TutorialManager.start_acknowledge(0.0)
	await TutorialManager.tutorial_acknowledged
	TutorialManager.fade_out()
	await GameManager.get_tree().create_timer(0.1).timeout
	TutorialManager.unpause()
	
	
pass
