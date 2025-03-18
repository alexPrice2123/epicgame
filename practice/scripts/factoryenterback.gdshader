shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float saturation;
void fragment() {
	 vec4 tex_color = texture(TEXTURE, UV);

    COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.1, 0, 0.1))), tex_color.rgb, saturation);
	COLOR.a = tex_color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
