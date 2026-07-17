extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	Dialogic.start(GameManager.next_cutscene)
	Dialogic.timeline_ended.connect(next_scene)

func next_scene():
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	GameManager.change_scene(GameManager.next_level)
