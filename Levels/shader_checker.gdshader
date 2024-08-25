shader_type canvas_item;

// the size of the texture to scale
uniform float tile_size = 20.0;
// custom color modulation
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
}

void fragment() {
    vec2 uv = world_position.xy / tile_size;
    uv = fract(uv);
	if (uv.x < 0.0) {
		uv.x += 1.0;
	}
	if (uv.y < 0.0) {
		uv.y += 1.0;
	}
    vec4 color = color1;
	if ((uv.x > 0.5) != (uv.y > 0.5)){
		color = color2;
	}
	COLOR = color;
}