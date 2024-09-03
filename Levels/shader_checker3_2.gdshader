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

group_uniforms OuterTile1_1;
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

// Will have no contribution below this
const float fade_in_lower_threshold = 2.0;
// Will have full contribution above this (but below the fade out)
const float fade_in_upper_threshold = 10.0;
// Will have full contribution below this (but above the fade in)
const float fade_out_lower_threshold = 500.0;
// Will have no contribution above this
const float fade_out_upper_threshold = 6000.0;

// Gices either a checker sample, average of the 2 colors, or combination of both,
//  depending on the calculated size of the tile in pixels
// checker_size is the size of the checker tile (2x2 checker pattern)
// color_a & color_b are the 2 colors to either average or get checker pattern value for
vec4 sample_checker_dynamic(vec2 position, float checker_size, vec4 color_a, vec4 color_b, out float contribution) {
	float tile_size_pixels = checker_size / scale;
	
	vec4 color = sample_color_checker(position, checker_size, color_a, color_b);
	
	if (tile_size_pixels < fade_in_lower_threshold || tile_size_pixels > fade_out_upper_threshold) {
		contribution = 0.0;
		return vec4(0.0);
	}
	else if (tile_size_pixels < fade_in_upper_threshold) {
		contribution = (tile_size_pixels - fade_in_lower_threshold) / (fade_in_upper_threshold - fade_in_lower_threshold);
		return color * contribution;
	}
	else if (tile_size_pixels > fade_out_lower_threshold){
		contribution = (fade_out_upper_threshold - tile_size_pixels) / (fade_out_upper_threshold - fade_out_lower_threshold);
		return color * contribution;
	}
	else {
		contribution = 1.0;
		return color;
	}
}

vec4 sample_depth(int depth, vec2 position, float depth_zero_size, vec4 color_a, vec4 color_b, out float contribution) {
	float tile_size_x = depth_zero_size / pow(float(tiles_within), float(depth));
	
	return sample_checker_dynamic(position, tile_size_x, color1, color2, contribution);
}

float based_log(float base, float x) {
	return (log(x) / log(base));
}

int get_highest_contributing_depth(float depth_zero_size) {
	float smallest_tile_size = fade_in_lower_threshold * scale;
	float depth = based_log(float(tiles_within), depth_zero_size / smallest_tile_size);
	depth = ceil(depth);
	return int(depth);
}

int get_lowest_contributing_depth(float depth_zero_size) {
	float biggest_tile_size = fade_out_upper_threshold * scale;
	float depth = based_log(float(tiles_within), depth_zero_size / biggest_tile_size);
	depth = ceil(depth);
	return int(depth);
}

// This is currently a somewhat limited implementation,
//  and should be replaced with a recursive call to allow for unlimited tiling
vec4 sample_complete(vec2 position) {
	float total_contribution = 0.0;
	vec4 total_color = vec4(0.0);
	
	float contrib_to_add = 0.0;
	
	int from = get_lowest_contributing_depth(tile_size);
	int to = get_highest_contributing_depth(tile_size);
	
	for (int i = from; i <= to; i++) {
		total_color += sample_depth(i, position, tile_size, color1, color2, contrib_to_add);
		total_contribution += contrib_to_add;
	}
	
	return total_color / total_contribution;
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
	
	vec4 color = vec4(0.0);
	int num_samples = 0;
	
	sample_dens = sample_density;
	if (!antialiasing_enabled) {
		sample_dens = 1;
	}
	
	for (int x = 0; x < sample_dens; x++) {
		for (int y = 0; y < sample_dens; y++) {
			vec2 offset = get_pixel_offset(x, y);
			color += sample_complete(world_position + offset);
			num_samples++;
		}
	}
	color /= float(num_samples);
	COLOR = color;
}
