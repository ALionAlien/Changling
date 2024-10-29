shader_type canvas_item;

uniform sampler2D mask;

void fragment()
{
	//vec4 skin = texture(TEXTURE, UV);
	//vec4 skin =  texture(screen_texture, UV);
	//vec4 mask_data = texture(mask, UV);
	//skin.a = mask_data.a;
	//COLOR = skin;
	COLOR = texture(TEXTURE, UV);
	COLOR.a = texture(mask, UV).a;
}

