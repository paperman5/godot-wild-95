@abstract class_name FoodItem
extends Node2D

var highlightable := true

@abstract func is_equal(other : FoodItem) -> bool

@export var stack_pos : Node2D
