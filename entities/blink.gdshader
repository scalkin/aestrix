shader_type canvas_item;

uniform bool active = false;

void fragment(){
	vec4 prev_color = texture(TEXTURE, UV);
	vec4 new_color = vec4(1.0, 1.0, 1.0, prev_color.a);
}