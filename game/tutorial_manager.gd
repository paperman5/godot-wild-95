extends CanvasLayer

signal tutorial_acknowledged(last_action : StringName)

const offscreen := Vector2(-500, 500)

@onready var root := %Root as Control
@onready var highlighter := %Highlighter as ColorRect
@onready var highlight_mat := highlighter.material as ShaderMaterial
@onready var text_lj := %TutorialTextLJ as RichTextLabel
@onready var text_rj := %TutorialTextRJ as RichTextLabel
@onready var text_cj := %TutorialTextCJ as RichTextLabel
@onready var text_continue := %ContinueText as RichTextLabel
@onready var anim := %AnimationPlayer as AnimationPlayer

var input_locked := false
var tutorial_active := false
# NEED TO KEEP A REFERENCE SO THE SCRIPT DOESN'T GET DEREFERENCED AND FAIL
var current_tutorial : TutorialScript
var skip_tutorials := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root.hide()
	clear_highlights()
	#highlight_points([Vector2(100, 100)], [30.0])

func highlight_nodes(nodes : Array[Node2D], radii : Array[float], offsets : Array[Vector2]):
	var node_ps : Array[Vector2] = []
	for i in range(len(nodes)):
		node_ps.append(Utils.get_node_screen_position(nodes[i], offsets[i]))
	highlight_points(node_ps, radii)

func _process(_delta: float) -> void:
	highlight_mat.set_shader_parameter("zoom", Utils.get_view_scale() * Vector2.ONE)
	if not tutorial_active or input_locked:
		return
	for action in ["move_down", "move_right", "move_up", "move_left"]:
		if Input.is_action_just_pressed(action):
			tutorial_acknowledged.emit(action)
			break

func begin_tutorial(tut : TutorialScript):
	if skip_tutorials:
		return
	current_tutorial = tut
	tutorial_active = true
	root.show()
	highlighter.show()
	text_continue.hide()
	clear_highlights()
	hide_text()
	await tut.show_tutorial()
	if anim.is_playing():
		await anim.animation_finished
	end_tutorial()

func end_tutorial():
	tutorial_active = false
	current_tutorial = null
	root.hide()
	highlighter.hide()
	hide_text()
	clear_highlights()

func hide_text():
	text_lj.hide()
	text_cj.hide()
	text_rj.hide()

func set_text(text : String, just : HorizontalAlignment, pos : Vector2):
	match just:
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT:
			text_lj.text = ""
			text_lj.size = text_lj.custom_minimum_size
			text_lj.show()
			text_lj.text = text
			text_lj.position = pos + Vector2.UP*text_lj.custom_minimum_size.y/2.0
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER:
			text_cj.text = ""
			text_cj.size = text_cj.custom_minimum_size
			text_cj.show()
			text_cj.text = text
			text_cj.position = pos - Vector2(text_cj.custom_minimum_size.x/2.0, text_cj.custom_minimum_size.y)
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT:
			text_rj.text = ""
			text_rj.size = text_rj.custom_minimum_size
			text_rj.show()
			text_rj.text = text
			text_rj.position = pos - Vector2(text_rj.custom_minimum_size.x, text_rj.custom_minimum_size.y/2.0)

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

func pause():
	GameManager.level.pause(false)

func unpause():
	GameManager.level.unpause(true)

func fade_in():
	anim.play("fade_in")
	await anim.animation_finished

func fade_out():
	anim.play("fade_out")

func _unlock_controls():
	input_locked = false
	text_continue.show()
	# show skip icon

func start_acknowledge(lock_time : float):
	if not is_zero_approx(lock_time):
		input_locked = true
		get_tree().create_timer(lock_time).timeout.connect(_unlock_controls)
	else:
		_unlock_controls()
