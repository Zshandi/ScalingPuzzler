shader_type canvas_item;

// the texture to repeat
uniform sampler2D texture_albedo;
// the size of the texture to scale
uniform vec2 texture_size = vec2(20.0, 20.0);
// custom color modulation
uniform vec4 modulate_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
}

void fragment() {
    vec2 uv = world_position.xy / texture_size;
    uv = fract(uv);
    vec4 texture_color = texture(texture_albedo, uv);
    COLOR = texture_color * modulate_color;
}