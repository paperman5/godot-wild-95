extends CanvasLayer

const offscreen := Vector2(-500, 500)

@onready var highlighter := %Highlighter as ColorRect
@onready var highlight_mat := highlighter.material as ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_highlights()

func get_node_highlight_point(node : Node2D) -> Vector2:
	var win_ft := get_window().get_final_transform()
	var p = (win_ft * node.get_global_transform_with_canvas()).origin - win_ft.get_origin()
	return p

func highlight_nodes(nodes : Array[Node2D], radii : Array[float]):
	var node_ps : Array[Vector2] = []
	for n in nodes:
		node_ps.append(get_node_highlight_point(n))
	highlight_points(node_ps, radii)

func _process(delta: float) -> void:
	highlight_mat.set_shader_parameter("zoom", Utils.get_view_scale() * Vector2.ONE)

func clear_highlights():
	var new_points : Array[Vector2] = []
	new_points.resize(4)
	new_points.fill(offscreen)
	var new_radii : Array[float] = []
	new_radii.resize(4)
	new_radii.fill(0.0)
	highlight_mat.set_shader_parameter("highlight_points", new_points)
	highlight_mat.set_shader_parameter("highlight_radii", new_radii)
	highlight_mat.set_shader_parameter("slot_a", offscreen)
	highlight_mat.set_shader_parameter("slot_b", offscreen)
	highlight_mat.set_shader_parameter("slot_r", 0.0)

func highlight_points(points : Array[Vector2], radii : Array[float]):
	var new_points : Array[Vector2] = []
	new_points.resize(4)
	new_points.fill(offscreen)
	for i in range(min(len(points), 4)):
		new_points[i] = points[i]
	highlight_mat.set_shader_parameter("highlight_points", new_points)
	
	var new_radii : Array[float] = []
	new_radii.resize(4)
	new_radii.fill(0.0)
	for i in range(min(len(radii), 4)):
		new_radii[i] = radii[i]
	highlight_mat.set_shader_parameter("highlight_radii", new_radii)

func highlight_slot(slot_a : Vector2, slot_b : Vector2, slot_r : float):
	highlight_mat.set_shader_parameter("slot_a", slot_a)
	highlight_mat.set_shader_parameter("slot_b", slot_b)
	highlight_mat.set_shader_parameter("slot_r", slot_r)
	
func set_highlight_blur_amount(amount : float):
	highlight_mat.set_shader_parameter("blur", amount)
