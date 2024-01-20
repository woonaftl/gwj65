shader_type canvas_item;

const float ALPHA_THRESHOLD = 0.01;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int outline_width : hint_range(0, 3) = 3;
uniform bool is_square = false;

void fragment() {
	bool is_outline = false;
	float float_outline_width = float(outline_width);
	
	if (texture(TEXTURE, UV).a < ALPHA_THRESHOLD) {
		for (float x = -float_outline_width; x <= float_outline_width; x++) {
			for (float y = -float_outline_width; y <= float_outline_width; y++) {
				float distance_from_source = abs(x) + abs(y);
				if (distance_from_source > 0.0 && (is_square || distance_from_source <= float_outline_width)) {
					if (texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2(x, y)).a >= ALPHA_THRESHOLD) {
						is_outline = true;
						continue;
					}
				}
			}
			if (is_outline) {
				continue;
			}
		}
	}
	if (is_outline) {
		COLOR = outline_color;
	}
}
