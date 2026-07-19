extends Node

enum IceCreamType {
	BooBerry = 0,
	ShockALot = 1,
	Vilenilla = 2
}

enum FoodType {
	MonsterMashBurger,
	Werewaffles
}

const IceCreamColors = {
	IceCreamType.BooBerry : Color.BLUE,
	IceCreamType.ShockALot : Color.SADDLE_BROWN,
	IceCreamType.Vilenilla : Color.FLORAL_WHITE
}

enum TableOrientation {
	HOR_LEFT, HOR_CENTER, HOR_RIGHT,
	VERT_LEFT, VERT_RIGHT, VERT_TOP,
	CORNER_LEFT, CORNER_RIGHT
}

const colors : Dictionary[String, Color] = {
	"matched" : Color.WEB_GREEN,
	"failed" : Color.FIREBRICK,
	"combo" : Color.GOLD
}

const TableTextureRegions = {
	TableOrientation.HOR_LEFT : Rect2(32, 32, 32, 64),
	TableOrientation.HOR_CENTER : Rect2(0, 32, 32, 64),
	TableOrientation.HOR_RIGHT : Rect2(32, 32, 32, 64),
	TableOrientation.VERT_LEFT : Rect2(64, 64, 32, 32),
	TableOrientation.VERT_RIGHT : Rect2(64, 64, 32, 32),
	TableOrientation.VERT_TOP : Rect2(64, 32, 32, 64),
	TableOrientation.CORNER_LEFT : Rect2(32, 32, 32, 64),
	TableOrientation.CORNER_RIGHT : Rect2(32, 32, 32, 64),
}

# All animations are at 5 fps
const DEFAULT_ANIM_SPEED := 5

func advance_animation_single_frame(anim : AnimationPlayer):
	var frame_time := 1.0 / Utils.DEFAULT_ANIM_SPEED
	#var new_time := snappedf(anim.current_animation_position, frame_time) + frame_time + 0.001
	var new_time := floorf(anim.current_animation_position / frame_time) * frame_time + frame_time + 0.001
	anim.seek(new_time, true)
	anim.pause()

func get_view_scale() -> float:
	## get_viewport().get_visible_rect() returns correct in-game pixel viewport size
	## get_window().size returns correct w&h of window including black bars at t&b
	#var orig_aspect = float(ProjectSettings.get_setting("display/window/size/viewport_width")) / float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	#var window_size := Vector2(get_window().size)
	#if window_size.aspect() < orig_aspect:
		#window_size = Vector2(window_size.x, window_size.x / orig_aspect)
	#var ingame_size := get_viewport().get_visible_rect()
	#var cam := get_viewport().get_camera_2d()
	#if is_instance_valid(cam):
		#return window_size.y * cam.zoom.y / ingame_size.size.y
	#return window_size.y / ingame_size.size.y
	var cam := get_viewport().get_camera_2d()
	var base_scale := get_window().get_final_transform().get_scale().y
	if is_instance_valid(cam):
		return base_scale * cam.zoom.y
	return base_scale

func get_node_screen_position(node : CanvasItem, offset := Vector2.ZERO) -> Vector2:
	var win_ft := get_window().get_final_transform()
	var offset_node := Node2D.new()
	node.add_child(offset_node)
	offset_node.position = offset
	var p = (win_ft * offset_node.get_global_transform_with_canvas()).origin - win_ft.get_origin()
	offset_node.free()
	return p

func get_node_ui_position(node : CanvasItem, offset := Vector2.ZERO) -> Vector2:
	var offset_node := Node2D.new()
	node.add_child(offset_node)
	offset_node.position = offset
	var p = offset_node.get_global_transform_with_canvas().get_origin()
	offset_node.free()
	return p
