// screws.scad -- contains auxiliary functions and modules to work with metric screws, nuts and washers */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

eps = 0.004;

// [real diameter, cutting diameter]
m2_5_screw_d = [2.4, 2.9];
// [cap diameter, cap hole diameter, washer_diameter]
m2_5_screw_cap_d = [4.4, 4.7, 6.5];
// [cap height, washer_height]
m2_5_screw_cap_h = [2.4, 0.2];

m2_screw_d = [1.94, 2.2];
m2_screw_cap_d = [3.7, 4, 4.8];
m2_screw_cap_h = [1.9, 0.3];

m3_screw_d = [2.6, 3.5];
m3_screw_cap_d = [5.2, 5.6, 7];
m3_screw_cap_h = [3, 0.2];

m4_screw_d = [3.6, 4.5];
m4_screw_cap_d = [6.5, 6.8, 8.5];
m4_screw_cap_h = [4.1, 0.4];

function _for_cutting() = is_undef($for_cutting) ? true : $for_cutting;

function m2_5_screw_d(for_cutting = true) = m2_5_screw_d[for_cutting ? 1 : 0];
function m3_screw_d(for_cutting = true) = m3_screw_d[for_cutting ? 1 : 0];

function m2_5_screw_cap_d(for_cutting = true) = m2_5_screw_cap_d[for_cutting ? 1 : 0];
function m3_screw_cap_d(for_cutting = true) = m3_screw_cap_d[for_cutting ? 1 : 0];

function m3_washer_d() = m3_screw_cap_d[2];

function m3_cap_h() = m3_screw_cap_h[0];

function m3_washer_h() = m3_screw_cap_h[1];

//-------------------------------------------------
module mX_screw(screw_l, cap_h, screw_sizes, cap_sizes, with_washer, no_support, head_above) {
    screw_d = screw_sizes[_for_cutting() ? 1 : 0];
    cap_d = cap_sizes[_for_cutting() ? (with_washer ? 2 : 1): 0];
    washer_h = cap_h[1];

    cap_draw_h = cap_h[0] + (with_washer ? washer_h : 0);
    translate([0, 0, head_above ? cap_draw_h : 0])
        mX_cap_cut(cap_draw_h, cap_d, screw_d, no_support, eps)

    // draw the actual washer if needed
    if (with_washer && !_for_cutting())
        cylinder(d = cap_sizes[2], h = washer_h);

    // screw body
    translate([0, 0, -screw_l - (head_above ? 0 : cap_draw_h)])
        cylinder(d = screw_d, h = screw_l + eps);
}


module m2_screw(length, with_washer = false, no_support = false, head_above = true) {
    mX_screw(length, m2_screw_cap_h, m2_screw_d, m2_screw_cap_d, with_washer, no_support, head_above);
}

module m3_screw(length, with_washer = false, no_support = false, head_above = true) {
    mX_screw(length, m3_screw_cap_h, m3_screw_d, m3_screw_cap_d, with_washer, no_support, head_above);
}

module m4_screw(length, with_washer = false, no_support = false, head_above = true) {
    mX_screw(length, m4_screw_cap_h, m4_screw_d, m4_screw_cap_d, with_washer, no_support, head_above);
}

module m2_5_screw(length, with_washer = false, no_support = false, head_above = true) {
    mX_screw(length, m2_5_screw_cap_h, m2_5_screw_d, m2_5_screw_cap_d, with_washer, no_support, head_above);
}
 
module mX_cap_cut(h, outer_d, inner_d, no_support, eps) {
    translate([0, 0, -h]) {
        cylinder(d = outer_d, h = h + eps);
        if (no_support) {
            intersection() {
                translate([0, 0, -0.2])
                    cylinder(d = outer_d, h = 0.4 + eps);
                
                translate([0, 0, -0.1])
                    cube([inner_d, outer_d, 0.2 + 2 * eps], center=true);
            }

            translate([0, 0, -0.2])
                cube([inner_d, inner_d, 0.4], center=true);
        }
    }

}           
