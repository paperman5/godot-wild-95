class_name IceCream
extends FoodItem

@export var flavors : Array[Utils.IceCreamType] = []
@export var strict_order := false
@export var max_flavors := 3
@export var alt_sprites : Texture

@onready var spr_group := %CanvasGroup as CanvasGroup
@onready var mat := spr_group.material as ShaderMaterial

func _ready() -> void:
	for c in [%Scoop0, %Scoop1, %Scoop2]:
		c.hide()
		if GameManager.use_alt_sprites:
			c.texture = alt_sprites
	GameManager.player.held_item_changed.connect(_on_held_item_changed)
	_on_held_item_changed.call_deferred(GameManager.player.get_held_order())

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
		var scoop_spr := get_node("%%Scoop%d" % (len(flavors)-1)) as Sprite2D
		scoop_spr.frame = flavor
		scoop_spr.show()
		stack_pos.position = get_node("Stack%d" % len(flavors)).position

func reset_visible():
	for i in len(flavors):
		var scoop_spr := get_node("%%Scoop%d" % i) as Sprite2D
		scoop_spr.frame = flavors[i]
		scoop_spr.show()

func scoop_count() -> int:
	return len(flavors)

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
