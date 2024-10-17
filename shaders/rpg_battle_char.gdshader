shader_type canvas_item;

uniform vec4 color : source_color;
uniform float flash_state : hint_range(0.0, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);

void vertex() {
	VERTEX += offset;
}

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	COLOR = mix(pixel_color, color, flash_state);
	COLOR.a *= pixel_color.a;
}
