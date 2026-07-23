shader_type canvas_item;
render_mode unshaded;

uniform int type : hint_enum("Disable", "Round", "Square") = 2;
uniform bool highlighted = false;
uniform bool rainbow = false;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
global uniform vec4 highlight_color;
global uniform float total_scale;

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
		result += texture(tex, from + DIRECTIONS[i] * size * total_scale).a;
	}
	return gtz(result);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
	return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	if (highlighted) {
		float phase = (UV.x + UV.y) / 2.5;
		float hue = fract(TIME * 0.35 + phase);
		vec4 c = rainbow ? vec4(hsv_to_rgb(vec3(hue, 1.0, 1.0)), 1.0) : highlight_color;
		vec4 sc = texture(screen_texture, SCREEN_UV);
		COLOR = mix( sc, c, check(screen_texture, SCREEN_UV, SCREEN_PIXEL_SIZE) * (1.0 - gtz(sc.a)) );
	}
	else {
		vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
		if (c.a > 0.0001) {
			c.rgb /= c.a;
		}
		COLOR *= c;
	}
}