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
@onready var mat := spr.material as ShaderMaterial

func _ready() -> void:
	food_type = food_type
	if is_instance_valid(GameManager.player):
		GameManager.player.held_item_changed.connect(_on_held_item_changed)
		_on_held_item_changed.call_deferred(GameManager.player.get_held_order())

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

func _on_held_item_changed(new : FoodItem):
	if not highlightable or not is_instance_valid(new):
		mat.set_shader_parameter("highlighted", false)
		mat.set_shader_parameter("rainbow", false)
		return
	if is_equal(new):
		mat.set_shader_parameter("highlighted", true)
		mat.set_shader_parameter("rainbow", true)
		return
	if GameManager.player.food_in_stack(self):
		mat.set_shader_parameter("highlighted", true)
		mat.set_shader_parameter("rainbow", false)
		return
	mat.set_shader_parameter("highlighted", false)
	mat.set_shader_parameter("rainbow", false)
