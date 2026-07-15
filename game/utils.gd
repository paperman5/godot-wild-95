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
	var new_time := snappedf(anim.current_animation_position, frame_time) + frame_time + 0.001
	anim.seek(new_time, true)
	anim.pause()
	
