shader_type canvas_item;
render_mode unshaded;

uniform float uncooked_alpha : hint_range(0.0, 1.0) = 0.5;
uniform float progress : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	c *= UV.x <= progress ? 1.0 : uncooked_alpha;
	COLOR = c;
}
