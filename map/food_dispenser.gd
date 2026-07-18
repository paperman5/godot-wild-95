@tool
class_name FoodDispenser
extends StaticBody2D

var food_textures = {
	Utils.FoodType.MonsterMashBurger : preload("uid://vo3mojygam5p"),
	Utils.FoodType.Werewaffles : preload("uid://dj1kplkvcxxnf")
}

@export var type : Utils.FoodType:
	set(value):
		type = value
		if is_instance_valid(spr):
			spr.texture = food_textures[value]

@export var counter_style : Utils.TableOrientation:
	set(value):
		counter_style = value
		if is_instance_valid(counter_spr):
			counter_spr.texture.region = Utils.TableTextureRegions[value]
			counter_spr.flip_h = Table.should_flip_texture(value)

@export var cooking_time := 5.0
@export var visible_counter := true:
	set(value):
		visible_counter = value
		if is_instance_valid(counter_spr):
			counter_spr.visible = value

@onready var spr := %Sprite as Sprite2D
@onready var counter_spr := %Counter as Sprite2D
@onready var cooking_timer := %CookingTimer as Timer

var spr_material : ShaderMaterial
var cooking := false
var food_ready := false

func _ready() -> void:
	type = type
	counter_style = counter_style
	spr_material = spr.material as ShaderMaterial

func _process(_delta: float) -> void:
	var progress := 0.0
	if food_ready:
		progress = 1.0
	elif cooking:
		progress = 1.0 - cooking_timer.time_left / cooking_time
	spr_material.set_shader_parameter("progress", progress)

func bump(_from_dir : Vector2) -> bool:
	if food_ready:
		var success = GameManager.player.add_cooked_food(type)
		if success:
			food_ready = false
			return true
	elif not cooking:
		cooking = true
		food_ready = false
		cooking_timer.start(cooking_time)
		return true
	return false


func _on_cooking_timer_timeout() -> void:
	cooking = false
	food_ready = true
