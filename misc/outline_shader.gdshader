shader_type canvas_item;

uniform int type : hint_enum("Disable", "Round", "Square") = 2;
uniform float thickness = 1.0;
uniform bool highlighted = false;
uniform bool rainbow = false;
global uniform vec4 highlight_color;

const vec2[8] DIRECTIONS = {
	vec2(1.0, 0.0),
	vec2(0.0, 1.0),
	vec2(-1.0, 0.0),
	vec2(0.0, -1.0),
	vec2(1.0, 1.0),
	vec2(-1.0, 1.0),
	vec2(-1.0, -1.0),
	vec2(1.0, -1.0)
};

float gtz(float input) { return max(0, sign(input)); }
// returns 1 if input > 0, else 0

float check(sampler2D tex, vec2 from, vec2 size) {
	float result = 0.0;
	for (int i = 0; i < 4 * type; i++) {
		result += texture(tex, from + DIRECTIONS[i] * size * thickness).a;
	}
	return gtz(result);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
	return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	float phase = (UV.x + UV.y) / 2.5;
	float hue = fract(TIME * 0.35 + phase);
	vec4 c = rainbow ? vec4(hsv_to_rgb(vec3(hue, 1.0, 1.0)), 1.0) : highlight_color;
	if (highlighted) {
		COLOR = mix( COLOR, c, check(TEXTURE, UV, TEXTURE_PIXEL_SIZE) * (1.0 - gtz(COLOR.a)) );
	}
	else {
		COLOR = texture(TEXTURE, UV);
	}
}
