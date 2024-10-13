shader_type canvas_item;

uniform sampler2D Skin; // assign skin sprite in inspector
uniform vec2 SkinDimension;  // assign length and width of skin sprite in editor

void fragment()
{
    // collect RGBA of pixel from sprite texture
	vec4 map = texture(TEXTURE, UV); 
	
	// scale the UV to the 64 x 64 "skin" sprite
    vec2 scaledUV = (map.rg * 255.0 + 0.5) / SkinDimension;
	
	// debug to check if any given scaleUV is being calculated correctly
	//if (abs(scaledUV.r - 0.164) < 0.001 && abs(scaledUV.g - 0.945) < 0.001)
    //	COLOR = vec4(1.0, 0.0, 0.0, map.a);
	
	// collect the rgba from the 'skin' sprite based on the scaledUV
    vec4 color = texture(Skin, scaledUV);
	
	// assign original sprite transparency
    color.a = map.a;
	
	// set new color
    COLOR = color;
}

