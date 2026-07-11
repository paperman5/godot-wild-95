class_name CookedFood
extends FoodItem

@export var food_type : Utils.FoodType

func is_equal(other : FoodItem) -> bool:
	if not is_instance_of(other, CookedFood):
		return false
	return food_type == other.food_type
