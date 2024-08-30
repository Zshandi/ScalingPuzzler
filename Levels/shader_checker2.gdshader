shader_type canvas_item;

group_uniforms Sizing;
/**
 * The size of the outer checker tiling (2 squares width)
 */
uniform float tile_size = 20.0;
/**
 * The number of checker tilings within the outer tiling
 * The size of these inner tiles will be tile_size / tiles_within
 */
uniform int tiles_within = 20;

group_uniforms OuterTile1;
/**
 * Color of the first inner tile, within the first outer tile.
 * Together with color2 will make up the average of the first outer tile.
 */
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
/**
 * Color of the second inner tile, within the first outer tile.
 * Together with color1 will make up the average of the first outer tile.
 */
uniform vec4 color2 : source_color = vec4(0.3, 0.3, 0.3, 1.0);

group_uniforms OuterTile2;
/**
 * Color of the first inner tile, within the second outer tile.
 * Together with color4 will make up the average of the second outer tile.
 */
uniform vec4 color3 : source_color = vec4(0.7, 0.7, 0.7, 1.0);
/**
 * Color of the second inner tile, within the second outer tile.
 * Together with color3 will make up the average of the second outer tile.
 */
uniform vec4 color4 : source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Antialiasing;

/**
 * The number of antialiasing samples per 2-pixel square,
 *  averaged to get the final color of the pixel.
 */
uniform int sample_density = 6;

group_uniforms SetViaScript;
/**
 * The current scale from camera to global transform.
 * Used to determine the global pixel size for antialiasing and color averaging.
 */
uniform float scale : hint_range(0.0, 15.0) = 1.0;

global uniform bool antialiasing_enabled;

varying flat int sample_dens;

varying vec2 world_position;
varying vec2 world_scale;
varying float canvas_scale;

varying vec2 screen_pixel_size;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
	world_scale = (MODEL_MATRIX * vec4(1.0)).xy;
	canvas_scale = length((inverse(CANVAS_MATRIX) * vec4(1.0)).xy);
}

// Samples a checker pattern at the given position
// checker_size is the size of the repeating checker tile (2x2 checker pattern)
// color_a & color_b are the 2 colors to get checker pattern value for
vec4 sample_color_checker(vec2 position, float checker_size, vec4 color_a, vec4 color_b) {
	vec2 uv = position.xy / checker_size;
	// Essentially mod 1, but works for negatives
    uv = uv - floor(uv);
	
    vec4 color = color_a;
	if ((uv.x > 0.5) != (uv.y > 0.5)){
		color = color_b;
	}
	return color;
}

// Gices either a checker sample, average of the 2 colors, or combination of both,
//  depending on the calculated size of the tile in pixels
// checker_size is the size of the checker tile (2x2 checker pattern)
// color_a & color_b are the 2 colors to either average or get checker pattern value for
// lower_pixel_size_threshold determines the tile size in pixels at which it is fully average
// lower_pixel_size_threshold determines the tile size in pixels at which it is fully checkered
vec4 sample_checker_dynamic(vec2 position, float checker_size, vec4 color_a, vec4 color_b) {
	// Will be fully averaged at this checker size
	const float lower_pixel_size_threshold = 2.0;
	// Will be fully averaged at this checker size
	const float upper_pixel_size_threshold = 10.0;
	
	float tile_size_pixels = checker_size / scale;
	
	vec4 color_avg;
	vec4 color_full;
	if (tile_size_pixels < upper_pixel_size_threshold) {
		color_avg = (color_a + color_b) / lower_pixel_size_threshold;
	}
	if (tile_size_pixels >= lower_pixel_size_threshold) {
		color_full = sample_color_checker(position, checker_size, color_a, color_b);
	}
	
	if (tile_size_pixels < lower_pixel_size_threshold) {
		return color_avg;
	}
	else if (tile_size_pixels < upper_pixel_size_threshold) {
		float full_contribution = (tile_size_pixels - lower_pixel_size_threshold) / upper_pixel_size_threshold;
		float avg_contribution = 1.0 - full_contribution;
		return color_full * full_contribution  +  color_avg * avg_contribution;
	}
	else {
		return color_full;
	}
}

// Samples the color at the given position
vec4 sample_color(vec2 position, float outer_tile_size, float inner_tile_size, vec4 color_1, vec4 color_2, vec4 color_3, vec4 color_4) {
	// Get smaller checker values
	vec4 color_a = sample_checker_dynamic(position, inner_tile_size, color1, color2);
	vec4 color_b = sample_checker_dynamic(position, inner_tile_size, color3, color4);
	
	// Then combine them in bigger checker
	return sample_checker_dynamic(position, outer_tile_size, color_a, color_b);
}

// Get pixel offset for anti-aliasing sample
// x is the x index (0 to num_samples)
// y is the y index (0 to num_samples)
vec2 get_pixel_offset(int x, int y) {
	float sample_distance = 2.0/float(sample_dens) * scale;
	float xf = float(x) * sample_distance;
	float yf = float(y) * sample_distance;
	return vec2(xf, yf);
}

void fragment() {
	screen_pixel_size = SCREEN_PIXEL_SIZE;
	float tile_size2 = tile_size / float(tiles_within);
	
	vec4 color = vec4(0.0);
	int num_samples = 0;
	
	sample_dens = sample_density;
	if (!antialiasing_enabled) {
		sample_dens = 1;
	}
	
	for (int x = 0; x < sample_dens; x++) {
		for (int y = 0; y < sample_dens; y++) {
			vec2 offset = get_pixel_offset(x, y);
			color += sample_color(world_position + offset, tile_size, tile_size2, color1, color2, color3, color4);
			num_samples++;
		}
	}
	color /= float(num_samples);
	COLOR = color;
}
