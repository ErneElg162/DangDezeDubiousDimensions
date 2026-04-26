shader_type sky;

uniform vec3 night_color : source_color = vec3(0.005, 0.01, 0.035);
uniform vec3 horizon_color : source_color = vec3(0.02, 0.04, 0.08);

uniform vec3 aurora_green : source_color = vec3(0.0, 1.0, 0.45);
uniform vec3 aurora_blue : source_color = vec3(0.15, 0.25, 1.0);
uniform vec3 aurora_purple : source_color = vec3(0.55, 0.05, 1.0);

uniform float aurora_intensity = 2.0;
uniform float aurora_speed = 0.08;
uniform float aurora_scale = 7.0;
uniform float aurora_height = 0.22;
uniform float aurora_thickness = 0.22;
uniform float curtain_sharpness = 1.8;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
        + (c - a) * u.y * (1.0 - u.x)
        + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
    float v = 0.0;
    float amp = 0.5;

    for (int i = 0; i < 5; i++) {
        v += amp * noise(p);
        p *= 2.0;
        amp *= 0.5;
    }

    return v;
}

void sky() {
    vec3 dir = normalize(EYEDIR);

    float up = clamp(dir.y, 0.0, 1.0);

    vec3 sky_col = mix(horizon_color, night_color, smoothstep(0.0, 0.8, up));

    float angle = atan(dir.x, dir.z);
    vec2 uv = vec2(angle * 1.4, dir.y * 3.0);

    float t = TIME * aurora_speed;

    float wave = sin(uv.x * 5.0 + t * 8.0) * 0.25;
    wave += sin(uv.x * 13.0 - t * 5.0) * 0.12;

    float n = fbm(vec2(uv.x * aurora_scale + t * 2.0, uv.y * 1.2 + wave));
    float n2 = fbm(vec2(uv.x * aurora_scale * 1.7 - t, uv.y * 2.0));

    float center = aurora_height + wave * 0.15 + (n - 0.5) * 0.12;

    float band = 1.0 - smoothstep(
        aurora_thickness,
        aurora_thickness + 0.25,
        abs(dir.y - center)
    );

    float streaks = pow(smoothstep(0.25, 1.0, n), curtain_sharpness);
    streaks *= smoothstep(0.15, 0.85, n2);

    float vertical_fade = smoothstep(0.02, 0.25, dir.y) * (1.0 - smoothstep(0.85, 1.0, dir.y));

    float aurora = band * streaks * vertical_fade;

    vec3 aurora_col = mix(aurora_green, aurora_blue, n2);
    aurora_col = mix(aurora_col, aurora_purple, smoothstep(0.65, 1.0, n));

    COLOR = sky_col + aurora_col * aurora * aurora_intensity;
}