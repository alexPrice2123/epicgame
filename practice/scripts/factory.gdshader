shader_type canvas_item;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	COLOR.rgb = COLOR.rrg;
}