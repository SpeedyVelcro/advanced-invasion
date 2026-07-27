shader_type canvas_item;
// Code will be throughly commented because I can't be trusted with shaders yet

void fragment() {
	// Get colour of current pixel
	vec4 c = texture(TEXTURE, UV);
	// Get brightest channel
	//float brightness = max(max(c.r, c.g), c.b);
	// Get average of channels
	float brightness = c.r * 0.299 + c.g * 0.587 + c.b * 0.114;
	float alpha = c.a;
	COLOR = vec4(brightness, brightness, brightness, COLOR.a);
}