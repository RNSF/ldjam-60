#include "pixel_match_settings.h"

#include <godot_cpp/core/class_db.hpp>

void PixelMatchSettings::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_threshold"), &PixelMatchSettings::get_threshold);
	ClassDB::bind_method(D_METHOD("set_threshold", "threshold"), &PixelMatchSettings::set_threshold);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "threshold", PROPERTY_HINT_RANGE, "0,1,0.01"),
			"set_threshold", "get_threshold");

	ClassDB::bind_method(D_METHOD("get_include_aa"), &PixelMatchSettings::get_include_aa);
	ClassDB::bind_method(D_METHOD("set_include_aa", "include_aa"), &PixelMatchSettings::set_include_aa);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "include_aa"), "set_include_aa", "get_include_aa");

	ClassDB::bind_method(D_METHOD("get_alpha"), &PixelMatchSettings::get_alpha);
	ClassDB::bind_method(D_METHOD("set_alpha", "alpha"), &PixelMatchSettings::set_alpha);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "alpha", PROPERTY_HINT_RANGE, "0,1,0.01"),
			"set_alpha", "get_alpha");

	ClassDB::bind_method(D_METHOD("get_aa_color"), &PixelMatchSettings::get_aa_color);
	ClassDB::bind_method(D_METHOD("set_aa_color", "aa_color"), &PixelMatchSettings::set_aa_color);
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "aa_color"), "set_aa_color", "get_aa_color");

	ClassDB::bind_method(D_METHOD("get_diff_color"), &PixelMatchSettings::get_diff_color);
	ClassDB::bind_method(D_METHOD("set_diff_color", "diff_color"), &PixelMatchSettings::set_diff_color);
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "diff_color"), "set_diff_color", "get_diff_color");

	ClassDB::bind_method(D_METHOD("get_diff_color_alt"), &PixelMatchSettings::get_diff_color_alt);
	ClassDB::bind_method(D_METHOD("set_diff_color_alt", "diff_color_alt"), &PixelMatchSettings::set_diff_color_alt);
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "diff_color_alt"), "set_diff_color_alt", "get_diff_color_alt");

	ClassDB::bind_method(D_METHOD("get_diff_mask"), &PixelMatchSettings::get_diff_mask);
	ClassDB::bind_method(D_METHOD("set_diff_mask", "diff_mask"), &PixelMatchSettings::set_diff_mask);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "diff_mask"), "set_diff_mask", "get_diff_mask");
}

float PixelMatchSettings::get_threshold() const { return threshold; }
void PixelMatchSettings::set_threshold(float p_threshold) { threshold = p_threshold; }

bool PixelMatchSettings::get_include_aa() const { return include_aa; }
void PixelMatchSettings::set_include_aa(bool p_include_aa) { include_aa = p_include_aa; }

float PixelMatchSettings::get_alpha() const { return alpha; }
void PixelMatchSettings::set_alpha(float p_alpha) { alpha = p_alpha; }

Color PixelMatchSettings::get_aa_color() const { return aa_color; }
void PixelMatchSettings::set_aa_color(const Color &p_aa_color) { aa_color = p_aa_color; }

Color PixelMatchSettings::get_diff_color() const { return diff_color; }
void PixelMatchSettings::set_diff_color(const Color &p_diff_color) { diff_color = p_diff_color; }

Color PixelMatchSettings::get_diff_color_alt() const { return diff_color_alt; }
void PixelMatchSettings::set_diff_color_alt(const Color &p_diff_color_alt) { diff_color_alt = p_diff_color_alt; }

bool PixelMatchSettings::get_diff_mask() const { return diff_mask; }
void PixelMatchSettings::set_diff_mask(bool p_diff_mask) { diff_mask = p_diff_mask; }