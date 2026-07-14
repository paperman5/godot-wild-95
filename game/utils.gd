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
