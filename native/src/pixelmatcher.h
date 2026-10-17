#pragma once

#include <cstdint>

#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/color.hpp>

#include "pixel_match_settings.h"

using namespace godot;

class PixelMatcher : public RefCounted {
	GDCLASS(PixelMatcher, RefCounted)

	struct Rgb8 {
		uint8_t r = 0;
		uint8_t g = 0;
		uint8_t b = 0;
	};

	float threshold = 0.1f;
	bool include_aa = false;
	float alpha = 0.1f;
	Rgb8 aa_color{ 255, 255, 0 };
	Rgb8 diff_color{ 255, 0, 0 };
	Rgb8 diff_color_alt{ 0, 0, 0 };
	bool diff_mask = false;

protected:
	static void _bind_methods();

public:
	PixelMatcher() = default;
	~PixelMatcher() override = default;
	int diff(const Ref<Image> &image1, const Ref<Image> &image2, const Ref<Image> &output, int width, int height, const Ref<PixelMatchSettings> &settings);

private:
	static Rgb8 to_rgb8(const Color &color);
	static bool is_8bit_quad_channel_image(const Ref<Image> &image);
	static bool is_pixel_antialiased(const uint8_t *image1, int x1, int y1, int width, int height, const uint8_t *image2);
	static bool pixel_has_many_siblings(const uint8_t *image, int x1, int y1, int width, int height);
	int pixelmatch(const uint8_t *image1, const uint8_t *image2, uint8_t *outputImage, int width, int height);
	static float color_delta(const uint8_t *image1, const uint8_t *image2, int k, int m, bool y_only = false);
	static float rgb2y(float r, float g, float b);
	static float rgb2i(float r, float g, float b);
	static float rgb2q(float r, float g, float b);
	static float blend(float c, float a);
	static void draw_pixel(uint8_t *outputImage, int pos, const Rgb8 &color);
	static void draw_gray_pixel(const uint8_t *image, int i, float alpha, uint8_t *outputImage);
	static bool pixels_equal(const uint8_t *image, int px1Pos, int px2Pos);
};