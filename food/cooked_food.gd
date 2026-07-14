class_name CookedFood
extends FoodItem

var anim_keys = {
	Utils.FoodType.MonsterMashBurger : "burger",
	Utils.FoodType.Werewaffles : "waffle"
}

@export var food_type : Utils.FoodType:
	set(value):
		food_type = value
		if is_instance_valid(anim):
			anim.current_animation = anim_keys[value] + "/RESET"
			anim.seek(0.0, true)

@onready var spr := %Sprite2D as Sprite2D
@onready var anim := %AnimationPlayer as AnimationPlayer

func _ready() -> void:
	food_type = food_type

func is_equal(other : FoodItem) -> bool:
	if not is_instance_of(other, CookedFood):
		return false
	return food_type == other.food_type
