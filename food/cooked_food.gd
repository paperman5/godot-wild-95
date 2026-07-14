@tool
class_name CookedFood
extends FoodItem

var anim_keys = {
	Utils.FoodType.MonsterMashBurger : "burger",
	Utils.FoodType.Werewaffles : "waffle"
}

@export var food_type : Utils.FoodType:
	set(value):
		food_type = value
		update_visuals()

@export var icon := false:
	set(value):
		icon = value
		update_visuals()

@onready var spr := %Sprite2D as Sprite2D
@onready var anim := %AnimationPlayer as AnimationPlayer

func _ready() -> void:
	food_type = food_type

func update_visuals():
	if is_instance_valid(anim):
		var str1 := str(anim_keys[food_type])
		var str2 := "icon" if icon else "big"
		anim.current_animation = str1 + "/" + str2
		anim.seek(0.0, true)

func is_equal(other : FoodItem) -> bool:
	if not is_instance_of(other, CookedFood):
		return false
	return food_type == other.food_type
