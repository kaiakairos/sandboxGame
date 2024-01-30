shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D mask_texture : repeat_disable, filter_nearest;

vec4 multiply(vec4 base, vec4 blend){
	return base * blend;
}

void fragment() {
	vec4 screen = texture(screen_texture,SCREEN_UV);
	float alphaMask = texture(mask_texture,UV).a;
	vec4 tex = texture(TEXTURE,UV);
	vec4 new = tex;
	
	if (screen.rgb != vec3(0.0,1.0,0.0)){
		new.r = tex.r*9.0;
		new.g = tex.g*8.2;
		new.b = tex.b*9.5;
	
		new = clamp(new,vec4(0.0),vec4(1.0));
		new = floor(new * 10.0)/10.0;
	
		COLOR = multiply(screen,new);
	}
	else{COLOR = screen;
	}
}

