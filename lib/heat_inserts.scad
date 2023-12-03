// heat_inserts.scad -- contains functions and constants realted to Heat Insert parts */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

eps = 0.004;

function m2_heat_insert_d() = 3.3;
function m3_heat_insert_d() = 4.5;
function m4_heat_insert_d() = 5.4;

function heat_insert_min_offset() = 1.5;

module m2_insert_vertical_hole(spacing, insert_height = 3, eps = eps) {
    _mX_insert_vertical_hole(spacing, m2_heat_insert_d(), insert_height, eps);
}

module m3_insert_vertical_hole(spacing, insert_height = 5, eps = eps) {
    _mX_insert_vertical_hole(spacing, m3_heat_insert_d(), insert_height, eps);
}

module m4_insert_vertical_hole(spacing, insert_height = 4, eps = eps) {
    _mX_insert_vertical_hole(spacing, m4_heat_insert_d(), insert_height, eps);
}

module _mX_insert_vertical_hole(spacing, d, insert_height, eps) {
    assert(spacing >= 0, "Spacing cannot be negative");
    translate([spacing + eps, 0, 0])
        rotate([0, -90, 0])
            cylinder(d = d, h = insert_height + 1 + eps);
}

module m4_insert_vertical_pad(spacing, angle = 45, eps = eps) {
    _mX_insert_vertical_pad(spacing, m4_heat_insert_d(), angle, eps);
}

module _mX_insert_vertical_pad(spacing, d, angle, eps) {
    assert(spacing > 0, "Spacing must be positive");
    assert(angle > 0 && angle <= 90, "Angle must be >0 and <=90");
    diams = _top_bottom_d(d, spacing + eps, angle);

    translate([-eps, 0, 0]) {
        rotate([0, 90, 0])
            cylinder(d = diams[0], h = spacing + eps);
    }


    intersection() {
        rotate([0, 90, 0])
            _mX_insert_volcano_pad(spacing, d, angle, eps);

        translate([-eps, -diams[0] / 2, -diams[1] / 2])
            cube([spacing + eps, diams[0], diams[1] / 2]);
    }
}

module m3_insert_volcano_pad(spacing, angle = 45, eps = eps) {
    _mX_insert_volcano_pad(spacing, m3_heat_insert_d(), angle, eps);
}

module _mX_insert_volcano_pad(spacing, d, angle, eps) {
    diams = _top_bottom_d(d, spacing + eps, angle);
    translate([0, 0, -eps])
        linear_extrude(height = spacing + eps, scale = diams[0] / diams[1])
            circle(d = diams[1]);
}   

module m2_heat_insert(h = 3.5) {
    _mX_heat_insert(m2_heat_insert_d(), 2, h);
}

module m3_heat_insert(h = 4) {
    _mX_heat_insert(m3_heat_insert_d(), 3, h);
}

module m4_heat_insert(h = 4) {
    _mX_heat_insert(m4_heat_insert_d(), 4, h);
}

module _mX_heat_insert(outer_d, inner_d, height) {
    color("gold")
        translate([0, 0, -height])
            linear_extrude(height = height)
                difference() {
                    circle(d = outer_d);
                    circle(d = inner_d);
                }
}

function _top_bottom_d(d, h, angle) =
    let (top_d = d + 2 * heat_insert_min_offset())
        [top_d, 2 * h / tan(angle) + top_d];

