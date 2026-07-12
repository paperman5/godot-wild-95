class_name IceCream
extends FoodItem

@export var flavors : Array[Utils.IceCreamType] = []
@export var strict_order := false
@export var max_flavors := 3

func _ready() -> void:
	for c in get_children():
		if is_instance_of(c, Sprite2D) and c.name != "Cup":
			c.hide()

func is_equal(other : FoodItem) -> bool:
	if not is_instance_of(other, IceCream):
		return false
	if len(flavors) != len(other.flavors):
		return false
	var this_copy = flavors.duplicate()
	var other_copy = other.flavors.duplicate()
	if not strict_order:
		this_copy.sort()
		other_copy.sort()
	for i in len(this_copy):
		if this_copy[i] != other_copy[i]:
			return false
	return true

func is_empty() -> bool:
	return len(flavors) == 0

func is_full() -> bool:
	return len(flavors) == max_flavors

func add_flavor(flavor : Utils.IceCreamType):
	if not is_full():
		flavors.append(flavor)
		var scoop_spr := get_node("Scoop%d" % (len(flavors)-1)) as Sprite2D
		scoop_spr.frame = flavor
		scoop_spr.show()
		stack_pos.position = get_node("Stack%d" % len(flavors)).position

func scoop_count() -> int:
	return len(flavors)
