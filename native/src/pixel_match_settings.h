#pragma once

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/color.hpp>

using namespace godot;

class PixelMatchSettings : public Resource {
	GDCLASS(PixelMatchSettings, Resource)

	float threshold = 0.1f; // matching threshold (0 to 1); smaller is more sensitive
	bool include_aa = false; // whether to skip anti-aliasing detection
	float alpha = 0.1f; // opacity of original image in diff output
	Color aa_color = Color(1, 1, 0); // color of anti-aliased pixels
	Color diff_color = Color(1, 0, 0); // color of different pixels
	Color diff_color_alt = Color(0, 0, 0); // color for dark-on-light differences
	bool diff_mask = false; // draw the diff over a transparent background

protected:
	static void _bind_methods();

public:
	float get_threshold() const;
	void set_threshold(float p_threshold);

	bool get_include_aa() const;
	void set_include_aa(bool p_include_aa);

	float get_alpha() const;
	void set_alpha(float p_alpha);

	Color get_aa_color() const;
	void set_aa_color(const Color &p_aa_color);

	Color get_diff_color() const;
	void set_diff_color(const Color &p_diff_color);

	Color get_diff_color_alt() const;
	void set_diff_color_alt(const Color &p_diff_color_alt);

	bool get_diff_mask() const;
	void set_diff_mask(bool p_diff_mask);
};