#include "pixelmatcher.h"

#include <algorithm>
#include <cmath>
#include <cstring>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

void PixelMatcher::_bind_methods() {
	ClassDB::bind_method(D_METHOD("diff", "image1", "image2", "output", "width", "height", "settings"), &PixelMatcher::diff, DEFVAL(Variant()));
}

PixelMatcher::Rgb8 PixelMatcher::to_rgb8(const Color &color) {
	auto to_byte = [](float v) {
		return static_cast<uint8_t>(std::clamp(static_cast<int>(std::lround(v * 255.0f)), 0, 255));
	};
	return Rgb8{ to_byte(color.r), to_byte(color.g), to_byte(color.b) };
}

float PixelMatcher::rgb2y(float r, float g, float b) {
	return r * 0.29889531f + g * 0.58662247f + b * 0.11448223f;
}

float PixelMatcher::rgb2i(float r, float g, float b) {
	return r * 0.59597799f - g * 0.27417610f - b * 0.32180189f;
}

float PixelMatcher::rgb2q(float r, float g, float b) {
	return r * 0.21147017f - g * 0.52261711f + b * 0.31114694f;
}

float PixelMatcher::blend(float c, float a) {
	return 255.0f + (c - 255.0f) * a;
}

void PixelMatcher::draw_pixel(uint8_t *outputImage, int pos, const Rgb8 &color) {
	// 8 bit color RGBA image required
	outputImage[pos + 0] = color.r;
	outputImage[pos + 1] = color.g;
	outputImage[pos + 2] = color.b;
	outputImage[pos + 3] = 255;
}

void PixelMatcher::draw_gray_pixel(const uint8_t *image, int i, float alpha, uint8_t *outputImage) {
	const float r = image[i + 0];
	const float g = image[i + 1];
	const float b = image[i + 2];
	const float a = image[i + 3];

	const int val = std::clamp(static_cast<int>(blend(rgb2y(r, g, b), alpha * a / 255.0f)), 0, 255);
	const uint8_t v = static_cast<uint8_t>(val);

	draw_pixel(outputImage, i, Rgb8{ v, v, v });
}

float PixelMatcher::color_delta(const uint8_t *img1, const uint8_t *img2, int k, int m, bool y_only) {
	float r1 = img1[k + 0];
	float g1 = img1[k + 1];
	float b1 = img1[k + 2];
	float a1 = img1[k + 3];

	float r2 = img2[m + 0];
	float g2 = img2[m + 1];
	float b2 = img2[m + 2];
	float a2 = img2[m + 3];

	if (a1 == a2 && r1 == r2 && g1 == g2 && b1 == b2) {
		return 0.0f;
	}

	if (a1 < 255.0f) {
		a1 /= 255.0f;
		r1 = blend(r1, a1);
		g1 = blend(g1, a1);
		b1 = blend(b1, a1);
	}

	if (a2 < 255.0f) {
		a2 /= 255.0f;
		r2 = blend(r2, a2);
		g2 = blend(g2, a2);
		b2 = blend(b2, a2);
	}

	const float y1 = rgb2y(r1, g1, b1);
	const float y2 = rgb2y(r2, g2, b2);
	const float y = y1 - y2;

	if (y_only) { // brightness difference only
		return y;
	}

	const float i = rgb2i(r1, g1, b1) - rgb2i(r2, g2, b2);
	const float q = rgb2q(r1, g1, b1) - rgb2q(r2, g2, b2);

	const float delta = 0.5053f * y * y + 0.299f * i * i + 0.1957f * q * q;

	// encode whether the pixel lightens or darkens in the sign
	return y1 > y2 ? -delta : delta;
}

bool PixelMatcher::pixel_has_many_siblings(const uint8_t *image, int x1, int y1, int width, int height) {
	const int x0 = std::max(x1 - 1, 0);
	const int y0 = std::max(y1 - 1, 0);
	const int x2 = std::min(x1 + 1, width - 1);
	const int y2 = std::min(y1 + 1, height - 1);
	const int pos = (y1 * width + x1) * 4;
	int zeroes = (x1 == x0 || x1 == x2 || y1 == y0 || y1 == y2) ? 1 : 0;

	// go through 8 adjacent pixels
	for (int x = x0; x <= x2; x++) {
		for (int y = y0; y <= y2; y++) {
			if (x == x1 && y == y1) {
				continue;
			}

			const int pos2 = (y * width + x) * 4;
			if (pixels_equal(image, pos, pos2)) {
				zeroes++;
			}

			if (zeroes > 2) {
				return true;
			}
		}
	}

	return false;
}

bool PixelMatcher::pixels_equal(const uint8_t *image, int px1Pos, int px2Pos) {
	return *(image + px1Pos) == *(image + px2Pos)
		&& *(image + px1Pos + 1) == *(image + px2Pos + 1)
		&& *(image + px1Pos + 2) == *(image + px2Pos + 2)
		&& *(image + px1Pos + 3) == *(image + px2Pos + 3);
}

bool PixelMatcher::is_8bit_quad_channel_image(const Ref<Image> &image) {
	return image.is_valid() && !image->is_empty() && image->get_format() == Image::FORMAT_RGBA8;
}

bool PixelMatcher::is_pixel_antialiased(const uint8_t *image1, int x1, int y1, int width, int height, const uint8_t *image2) {
	const int x0 = std::max(x1 - 1, 0);
	const int y0 = std::max(y1 - 1, 0);
	const int x2 = std::min(x1 + 1, width - 1);
	const int y2 = std::min(y1 + 1, height - 1);
	const int pos = (y1 * width + x1) * 4;
	int zeroes = (x1 == x0 || x1 == x2 || y1 == y0 || y1 == y2) ? 1 : 0;
	float min_delta = 0.0f;
	float max_delta = 0.0f;
	int min_x = 0, min_y = 0, max_x = 0, max_y = 0;

	// go through 8 adjacent pixels
	for (int x = x0; x <= x2; x++) {
		for (int y = y0; y <= y2; y++) {
			if (x == x1 && y == y1) {
				continue;
			}

			// brightness delta between the center pixel and adjacent one
			const float delta = color_delta(image1, image1, pos, (y * width + x) * 4, true);

			// count the number of equal, darker and brighter adjacent pixels
			if (delta == 0.0f) {
				zeroes++;
				// if found more than 2 equal siblings, it's definitely not anti-aliasing
				if (zeroes > 2) {
					return false;
				}
			} else if (delta < min_delta) { // remember the darkest pixel
				min_delta = delta;
				min_x = x;
				min_y = y;
			} else if (delta > max_delta) { // remember the brightest pixel
				max_delta = delta;
				max_x = x;
				max_y = y;
			}
		}
	}

	// if there are no both darker and brighter pixels among siblings, it's not anti-aliasing
	if (min_delta == 0.0f || max_delta == 0.0f) {
		return false;
	}

	// if either the darkest or the brightest pixel has 3+ equal siblings in both images
	// (definitely not anti-aliased), this pixel is anti-aliased
	return (pixel_has_many_siblings(image1, min_x, min_y, width, height) &&
				   pixel_has_many_siblings(image2, min_x, min_y, width, height)) ||
			(pixel_has_many_siblings(image1, max_x, max_y, width, height) &&
					pixel_has_many_siblings(image2, max_x, max_y, width, height));
}

// All buffers are RGBA8, width * height pixels. outputImage may be nullptr.
// Returns the number of different pixels.
int PixelMatcher::pixelmatch(const uint8_t *image1, const uint8_t *image2, uint8_t *outputImage, int width, int height) {
	// check if images are identical
	const size_t length = size_t(width) * size_t(height) * 4;
	if (std::memcmp(image1, image2, length) == 0) { // fast path if identical
		if (outputImage && !diff_mask) {
			for (int i = 0; i < width * height; i++) {
				draw_gray_pixel(image1, i * 4, alpha, outputImage);
			}
		}
		return 0;
	}

	// maximum acceptable square distance between two colors;
	// 35215 is the maximum possible value for the YIQ difference metric
	const float max_delta = 35215.0f * threshold * threshold;
	int diff_count = 0;

	// compare each pixel of one image against the other one
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			const int pos = (y * width + x) * 4;

			// squared YUV distance between colors at this pixel position, negative if the img2 pixel is darker
			const float delta = color_delta(image1, image2, pos, pos);

			// the color difference is above the threshold
			if (std::fabs(delta) > max_delta) {
				// check it's a real rendering difference or just anti-aliasing
				if (!include_aa &&
						(is_pixel_antialiased(image1, x, y, width, height, image2) ||
								is_pixel_antialiased(image2, x, y, width, height, image1))) {
					// anti-aliasing: draw it in aa_color and do not count it as a difference;
					// such pixels are not included in a mask
					if (outputImage && !diff_mask) {
						draw_pixel(outputImage, pos, aa_color);
					}
				} else {
					// substantial difference not caused by anti-aliasing
					if (outputImage) {
						draw_pixel(outputImage, pos, delta < 0.0f ? diff_color_alt : diff_color);
					}
					diff_count++;
				}
			} else if (outputImage && !diff_mask) {
				// pixels are similar; draw background as grayscale image blended with white
				draw_gray_pixel(image1, pos, alpha, outputImage);
			}
		}
	}

	return diff_count;
}

// Returns the number of different pixels, or -1 on error.
// `output` may be a null Ref to skip drawing; otherwise it is modified in place.
int PixelMatcher::diff(const Ref<Image> &image1, const Ref<Image> &image2, const Ref<Image> &output,
		int width, int height, const Ref<PixelMatchSettings> &p_settings) {
	if (image1.is_null() || image2.is_null()) {
		UtilityFunctions::push_error("Two images are required.");
		return -1;
	}
	if (!is_8bit_quad_channel_image(image1) || !is_8bit_quad_channel_image(image2) ||
			(output.is_valid() && !is_8bit_quad_channel_image(output))) {
		UtilityFunctions::push_error("Images must be RGBA8.");
		return -1;
	}
	if (image1->get_size() != image2->get_size() ||
			(output.is_valid() && output->get_size() != image1->get_size())) {
		UtilityFunctions::push_error("Image sizes do not match.");
		return -1;
	}
	if (image1->get_width() != width || image1->get_height() != height) {
		UtilityFunctions::push_error("width and height do not match the images.");
		return -1;
	}

	// Copy the settings into members once so the pixel loop touches no Godot objects.
	Ref<PixelMatchSettings> settings = p_settings;
	if (settings.is_null()) {
		settings.instantiate();
	}
	threshold = settings->get_threshold();
	include_aa = settings->get_include_aa();
	alpha = settings->get_alpha();
	aa_color = to_rgb8(settings->get_aa_color());
	diff_color = to_rgb8(settings->get_diff_color());
	diff_color_alt = to_rgb8(settings->get_diff_color_alt());
	diff_mask = settings->get_diff_mask();

	const int64_t length = int64_t(width) * height * 4;
	const PackedByteArray a_data = image1->get_data();
	const PackedByteArray b_data = image2->get_data();
	if (a_data.size() != length || b_data.size() != length) {
		UtilityFunctions::push_error("Image data must contain 4 bytes per pixel.");
		return -1;
	}

	// get_data() returns a copy, so draw into a copy of the output's bytes and set it back afterwards.
	// Starting from the existing bytes keeps untouched pixels as they were, like the GDScript version.
	PackedByteArray out_data;
	uint8_t *out_ptr = nullptr;
	if (output.is_valid()) {
		out_data = output->get_data();
		if (out_data.size() != length) { // e.g. output has mipmaps
			UtilityFunctions::push_error("Output image must be RGBA8 without mipmaps.");
			return -1;
		}
		out_ptr = out_data.ptrw();
	}

	const int count = pixelmatch(a_data.ptr(), b_data.ptr(), out_ptr, width, height);

	if (output.is_valid()) {
		output->set_data(width, height, false, Image::FORMAT_RGBA8, out_data);
	}

	return count;
}