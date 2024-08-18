shader_type canvas_item;

uniform sampler2D texture_albedo;
uniform vec2 texture_size = vec2(20.0, 20.0);
uniform vec4 modulate_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv = FRAGCOORD.xy / texture_size;
    uv = fract(uv);
    vec4 texture_color = texture(texture_albedo, uv);
    COLOR = texture_color * modulate_color;
}