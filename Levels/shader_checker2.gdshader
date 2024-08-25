shader_type canvas_item;

// the size of the checker tiling (2 squares)
uniform float tile_size = 20.0;
// the number of checker tilings within the outer tiling
uniform int tiles_within = 20;
// custom color modulation
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.3, 0.3, 0.3, 1.0);
// custom color modulation
uniform vec4 color3 : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform vec4 color4 : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float scale : hint_range(0.0, 15.0) = 1.0;

uniform int sample_density = 6;

varying vec2 world_position;
varying vec2 world_scale;
varying float canvas_scale;

varying vec2 screen_pixel_size;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
	world_scale = (MODEL_MATRIX * vec4(1.0)).xy;
	canvas_scale = length((inverse(CANVAS_MATRIX) * vec4(1.0)).xy);
}

vec2 get_uv(vec2 position, float tile_size_param) {
	vec2 uv = position.xy / tile_size_param;
    uv = fract(uv);
	if (uv.x < 0.0) {
		uv.x += 1.0;
	}
	if (uv.y < 0.0) {
		uv.y += 1.0;
	}
	return uv;
}

vec4 sample_color_avg(vec2 position) {
	vec2 uv = world_position.xy / tile_size;
    uv = fract(uv);
	if (uv.x < 0.0) {
		uv.x += 1.0;
	}
	if (uv.y < 0.0) {
		uv.y += 1.0;
	}
    vec4 color = (color1 + color2) / 2.0;
	if ((uv.x > 0.5) != (uv.y > 0.5)){
		color = (color3 + color4) / 2.0;
	}
	return color;
}

vec4 sample_color_full(vec2 position, float tile_size2) {
    vec2 uv = get_uv(position, tile_size);
    vec2 uv2 = get_uv(position, tile_size2);
	
    vec4 color = color1;
	if ((uv.x > 0.5) != (uv.y > 0.5)){
		color = color3;
	}
	if ((uv2.x > 0.5) != (uv2.y > 0.5)){
		if (color == color1) {
			color = color2;
		}
		else {
			color = color4;
		}
	}
	return color;
}

vec4 sample_color(vec2 position, float tile_size2) {
	float tile_2_size_pixels = tile_size2 / scale;
	if (tile_2_size_pixels < 2.0) {
		return sample_color_avg(position);
	}
	else if (tile_2_size_pixels < 10.0) {
		float full_contribution = (tile_2_size_pixels - 2.0) / 10.0;
		float avg_contribution = 1.0 - full_contribution;
		vec4 color = sample_color_full(position, tile_size2) * full_contribution;
		color += sample_color_avg(position) * avg_contribution;
		return color;
	}
	else {
		return sample_color_full(position, tile_size2);
	}
}

vec2 get_pixel_offset(int x, int y) {
	float sample_distance = 2.0/float(sample_density) * scale;
	float xf = float(x) * sample_distance;
	float yf = float(y) * sample_distance;
	return vec2(xf, yf);
}

void fragment() {
	screen_pixel_size = SCREEN_PIXEL_SIZE;
	float tile_size2 = tile_size / float(tiles_within);
	
	vec4 color = vec4(0.0);
	int num_samples = 0;
	
	for (int x = 0; x < sample_density; x++) {
		for (int y = 0; y < sample_density; y++) {
			vec2 offset = get_pixel_offset(x, y);
			color += sample_color(world_position + offset, tile_size2);
			num_samples++;
		}
	}
	color /= float(num_samples);
	COLOR = color;//vec4(vec3(point_size/3.0), 1.0);
}
