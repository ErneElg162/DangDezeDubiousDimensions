shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;


uniform float speed: hint_range(0.0, 10.0, 0.01) = 1.0;
uniform float octaves: hint_range(1.0, 10.0, 1.0) = 5.0;
uniform float amp_start: hint_range(0.0, 5.0, 0.01) = 1.5;
uniform float amp_change: hint_range(0.0, 5.0, 0.01) = 1.5;
uniform float freq_change: hint_range(0.0, 5.0, 0.01) = 1.8;
uniform float distortion: hint_range(0.0, 5.0, 0.01) = 1.2;
uniform float scale: hint_range(0.0, 5.0, 0.01) = 3.0;
uniform float slice: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float width: hint_range(0.1, 5.0, 0.01) = 1.0;
uniform float height: hint_range(0.1, 5.0, 0.01) = 1.0;
uniform float alpha_threshold: hint_range(0.0, 1.0, 0.01) = 0.0;

varying vec3 object_pos;

vec3 hsv2rgb(float h, float s, float v){
	vec3 color = clamp(abs(fract(h + vec3(3.0, 2.0, 1.0) / 3.0) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
	return mix(vec3(1.0), color, s) * v;
}

float saw(float x){
	return abs(fract(x) - 0.5);
}

vec3 saw3d(vec3 p) {
	return vec3(
		saw(p.z + saw(p.x)),
		saw(p.z + saw(p.y)),
		saw(p.y + saw(p.x))
	);
}

float animated_noise(vec3 p, float noise_speed){
	float result = 0.0;
	float amp = amp_start;
	vec3 noise_point = p;
	for (float i = 0.0; i < octaves; i++) {
		p += saw3d(noise_point) + TIME * noise_speed;
		noise_point *= freq_change;
		amp *= amp_change;
		p *= distortion;
		result += (saw(p.z + saw(p.x + saw(p.y)))) / amp;
	}
	return result;	
}

void vertex() {
	object_pos = VERTEX;
}

void fragment() {
	vec3 pos = object_pos;
	pos.y += 1.0;
	float radial = 1.0 - smoothstep(0.0, width, length(pos.xz));
	float vertical = smoothstep(height, -height, pos.y);
	float m = radial * vertical;
	vec3 p = pos * scale - vec3(0.0, TIME * speed * 0.01, slice);
	float fire =
		m * 0.5 * animated_noise(p, 0.05) + 
		m * m * animated_noise(p * 0.2, 0.05);
	vec3 color = hsv2rgb(fire * 1.5 + 0.9, 0.6, 1.0) * fire * fire * 200.0;
	float avg = (color.r + color.g + color.b) / 3.0;
	ALBEDO = color;
	ALPHA = avg <= alpha_threshold ? 0.0 : 1.0;
	//COLOR = vec4(color, 1.0);
}
	