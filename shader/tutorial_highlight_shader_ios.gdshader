shader_type canvas_item;
render_mode unshaded;

#include "dither_patterns.gdshaderinc"

uniform float blur = 20.0;
uniform vec4 back_color : source_color = vec4(0.0, 0.0, 0.0, 0.7);
uniform vec2[4] highlight_points;
uniform float[4] highlight_radii;
uniform vec2 slot_a = vec2(0.0);
uniform vec2 slot_b = vec2(0.0);
uniform float slot_r = 20.0;
global uniform float total_scale;
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b, in float r ) {
    vec2 ba = b-a;
    vec2 pa = p-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length(pa-h*ba)-r;
}

void fragment() {
	float sdf = 1.0;
	vec2 screen_uv_rounded = floor(SCREEN_UV / floor(total_scale) / SCREEN_PIXEL_SIZE) * SCREEN_PIXEL_SIZE * floor(total_scale);
	vec2 screen_pixel_size_adj_round = SCREEN_PIXEL_SIZE * floor(total_scale);
	vec2 screen_pixel_size_adj = SCREEN_PIXEL_SIZE * total_scale;
	float aspect = float(SCREEN_PIXEL_SIZE.y) / float(SCREEN_PIXEL_SIZE.x);
	float blur_r_uv = blur / 2.0 * screen_pixel_size_adj.y;
	float slot_r_uv = slot_r / 2.0 * screen_pixel_size_adj.y;
	// Slot rendering: rounded line
	vec2 pa_uv = slot_a * vec2(aspect, 1.0) * SCREEN_PIXEL_SIZE;
	vec2 pb_uv = slot_b * vec2(aspect, 1.0) * SCREEN_PIXEL_SIZE;
	float line = sdSegment(screen_uv_rounded * vec2(aspect, 1.0), pa_uv, pb_uv, slot_r_uv);
	sdf *= smoothstep(clamp(slot_r_uv - blur_r_uv, 0.0, 1.0), clamp(slot_r_uv + blur_r_uv, 0.0, 1.0), line);
	
	// Point rendering
	for (int i = 0; i < 4; i++) {
		vec2 p_uv = highlight_points[i] * vec2(aspect, 1.0) * SCREEN_PIXEL_SIZE;
		float dist = distance(screen_uv_rounded * vec2(aspect, 1.0), p_uv);
		float r = highlight_radii[i] / 2.0 * screen_pixel_size_adj.y;
		sdf *= smoothstep(clamp(r - blur_r_uv, 0.0, 1.0), clamp(r + blur_r_uv, 0.0, 1.0), dist);
	}
	
	float dither = dither4x4(SCREEN_UV / screen_pixel_size_adj_round, sdf);
	
	vec4 c = mix(vec4(vec3(0.0), 0.0), back_color, dither * back_color.a);
	
	COLOR = c * modulate;
}
