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

const food_scenes = {
	FoodType.MonsterMashBurger : "",
	FoodType.Werewaffles : ""
}

var food_textures = {
	Utils.FoodType.MonsterMashBurger : preload("uid://vo3mojygam5p"),
	Utils.FoodType.Werewaffles : preload("uid://dj1kplkvcxxnf")
}
