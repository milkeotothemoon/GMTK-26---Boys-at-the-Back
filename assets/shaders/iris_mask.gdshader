shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 2.0;
uniform vec2 center = vec2(0.5, 0.5);
uniform float aspect = 1.7777778;

void fragment() {
	vec2 d = UV - center;
	d.x *= aspect;
	COLOR = vec4(0.0, 0.0, 0.0, step(radius, length(d)));
}