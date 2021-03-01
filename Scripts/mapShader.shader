shader_type canvas_item;
uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;
uniform sampler2D tex4;
uniform sampler2D tex5;
uniform sampler2D tex6;
uniform sampler2D tex7;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec2 flipped_screen = vec2(SCREEN_UV.x, 1.0-SCREEN_UV.y);
	if (COLOR.r>.5 && COLOR.g > .5 && COLOR.b > .5){
		COLOR = texture(tex7, flipped_screen);
	} else if (COLOR.r>.5 && COLOR.g > .5 && COLOR.b < .5){
		COLOR = texture(tex2, flipped_screen);
	}else if (COLOR.r>.5 && COLOR.g < .5 && COLOR.b > .5){
		COLOR = texture(tex3, flipped_screen);
	}else if (COLOR.r>.5 && COLOR.g < .5 && COLOR.b < .5){
		COLOR = texture(tex1, flipped_screen);
	}else if (COLOR.r<.5 && COLOR.g > .5 && COLOR.b > .5){
		COLOR = texture(tex5, flipped_screen);
	}else if (COLOR.r<.5 && COLOR.g > .5 && COLOR.b < .5){
		COLOR = texture(tex3, flipped_screen);
	}else if (COLOR.r<.5 && COLOR.g < .5 && COLOR.b > .5){
		COLOR = texture(tex7, flipped_screen);
	}else if (COLOR.r<.5 && COLOR.g < .5 && COLOR.b < .5){
		COLOR = vec4(0,0,0,0)
	}
		
    
}