shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture;

uniform vec2 zoom = vec2(1.0);
uniform float blur = 20.0;
uniform vec4 back_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform vec2[4] highlight_points;
uniform float[4] highlight_radii;
uniform vec2 slot_a = vec2(0.0);
uniform vec2 slot_b = vec2(0.0);
uniform float slot_r = 20.0;
uniform bool desaturate = true;
uniform float desaturate_amt : hint_range(0.0, 1.0) = 0.5;
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

float dither8x8(vec2 position, float brightness) {
  int x = int(mod(position.x, 8.0));
  int y = int(mod(position.y, 8.0));
  int index = x + y * 8;
  float limit = 0.0;

  if (x < 8) {
    if (index == 0) limit = 0.015625;
    if (index == 1) limit = 0.515625;
    if (index == 2) limit = 0.140625;
    if (index == 3) limit = 0.640625;
    if (index == 4) limit = 0.046875;
    if (index == 5) limit = 0.546875;
    if (index == 6) limit = 0.171875;
    if (index == 7) limit = 0.671875;
    if (index == 8) limit = 0.765625;
    if (index == 9) limit = 0.265625;
    if (index == 10) limit = 0.890625;
    if (index == 11) limit = 0.390625;
    if (index == 12) limit = 0.796875;
    if (index == 13) limit = 0.296875;
    if (index == 14) limit = 0.921875;
    if (index == 15) limit = 0.421875;
    if (index == 16) limit = 0.203125;
    if (index == 17) limit = 0.703125;
    if (index == 18) limit = 0.078125;
    if (index == 19) limit = 0.578125;
    if (index == 20) limit = 0.234375;
    if (index == 21) limit = 0.734375;
    if (index == 22) limit = 0.109375;
    if (index == 23) limit = 0.609375;
    if (index == 24) limit = 0.953125;
    if (index == 25) limit = 0.453125;
    if (index == 26) limit = 0.828125;
    if (index == 27) limit = 0.328125;
    if (index == 28) limit = 0.984375;
    if (index == 29) limit = 0.484375;
    if (index == 30) limit = 0.859375;
    if (index == 31) limit = 0.359375;
    if (index == 32) limit = 0.0625;
    if (index == 33) limit = 0.5625;
    if (index == 34) limit = 0.1875;
    if (index == 35) limit = 0.6875;
    if (index == 36) limit = 0.03125;
    if (index == 37) limit = 0.53125;
    if (index == 38) limit = 0.15625;
    if (index == 39) limit = 0.65625;
    if (index == 40) limit = 0.8125;
    if (index == 41) limit = 0.3125;
    if (index == 42) limit = 0.9375;
    if (index == 43) limit = 0.4375;
    if (index == 44) limit = 0.78125;
    if (index == 45) limit = 0.28125;
    if (index == 46) limit = 0.90625;
    if (index == 47) limit = 0.40625;
    if (index == 48) limit = 0.25;
    if (index == 49) limit = 0.75;
    if (index == 50) limit = 0.125;
    if (index == 51) limit = 0.625;
    if (index == 52) limit = 0.21875;
    if (index == 53) limit = 0.71875;
    if (index == 54) limit = 0.09375;
    if (index == 55) limit = 0.59375;
    if (index == 56) limit = 1.0;
    if (index == 57) limit = 0.5;
    if (index == 58) limit = 0.875;
    if (index == 59) limit = 0.375;
    if (index == 60) limit = 0.96875;
    if (index == 61) limit = 0.46875;
    if (index == 62) limit = 0.84375;
    if (index == 63) limit = 0.34375;
  }

  return brightness < limit ? 0.0 : 1.0;
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b, in float r )
{
    vec2 ba = b-a;
    vec2 pa = p-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length(pa-h*ba)-r;
}

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);
	vec4 c = vec4(back_color.rgb, 1.0);
	vec2 screen_pixel_size = SCREEN_PIXEL_SIZE;
	vec2 big_screen_pixel_size = SCREEN_PIXEL_SIZE * zoom;
	float aspect = float(SCREEN_PIXEL_SIZE.y) / float(SCREEN_PIXEL_SIZE.x);
	vec2 uv = floor(UV/big_screen_pixel_size)*big_screen_pixel_size;
	float blur_r = big_screen_pixel_size.y * blur / 2.0;
	
	// Slot rendering: rounded line
	vec2 pa = slot_a * vec2(aspect, 1.0) * screen_pixel_size;
	vec2 pb = slot_b * vec2(aspect, 1.0) * screen_pixel_size;
	float line = sdSegment(vec2(uv.x*aspect, uv.y), pa, pb, slot_r*screen_pixel_size.y);
	float line_r = slot_r*big_screen_pixel_size.y;
	c.a *= smoothstep(clamp(line_r-blur_r, 0.0, 1.0), clamp(line_r+blur_r, 0.0, 1.0), line);
	
	// Point rendering
	for (int i = 0; i < 4; i++) {
		vec2 p = vec2(highlight_points[i].x * aspect, highlight_points[i].y) * screen_pixel_size;
		p = floor(p/big_screen_pixel_size)*big_screen_pixel_size;
		float r = highlight_radii[i] * big_screen_pixel_size.y;
		c.a *= smoothstep(clamp(r-blur_r, 0.0, 1.0), clamp(r+blur_r, 0.0, 1.0), distance(vec2(uv.x*aspect,uv.y), p));
	}
	float dither = dither8x8(floor(UV/big_screen_pixel_size), c.a);
	if (desaturate) {
		screen.rgb = mix(screen.rgb, vec3(0.299 * screen.r + 0.587 * screen.g + 0.114 * screen.b), dither * desaturate_amt);
	}
	screen.rgb = mix(screen.rgb, screen.rgb * back_color.rgb, dither * back_color.a * modulate.a);
	COLOR = screen;
}
