extends CanvasLayer

@onready var highlighter := %Highlighter as ColorRect
@onready var highlight_mat := highlighter.material as ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_size := get_viewport().get_texture().get_size()
	highlight_mat.set_shader_parameter("screen_size", Vector2i(screen_size))
