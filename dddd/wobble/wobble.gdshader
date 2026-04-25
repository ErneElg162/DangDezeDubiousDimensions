shader_type spatial;

uniform float amount : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	float wobble = sin(amount * PI * 2.0) * (1.0 - amount) * 0.1;
    VERTEX.xz *= (1.0 + wobble);
    VERTEX.y *= (1.0 - wobble * 0.5);
}

void fragment() {}