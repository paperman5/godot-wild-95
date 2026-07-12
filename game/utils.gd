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
	LEFT, CENTER, RIGHT
}

const TableTextureRegions = {
	TableOrientation.LEFT : Rect2(32, 32, 32, 64),
	TableOrientation.CENTER : Rect2(0, 32, 32, 64),
	TableOrientation.RIGHT : Rect2(32, 32, 32, 64)
}
