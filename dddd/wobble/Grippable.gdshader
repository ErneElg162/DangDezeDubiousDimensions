shader_type spatial;

void vertex() {
	float wobble = sin(amount * PI * 2.0) * (1.0 - amount) * 0.1;
    VERTEX.xz *= (1.0 + wobble);
    VERTEX.y *= (1.0 - wobble * 0.5);
}

void fragment() {
	ALBEDO = vec3(219, 103, 255);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
