shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 screen = texture(screen_texture,SCREEN_UV);
	vec4 tex = texture(TEXTURE,UV);
	COLOR = vec4(0.0);
	if(screen.rgb == vec3(0.0,1.0,0.0)){
		COLOR = tex;
	}
}
