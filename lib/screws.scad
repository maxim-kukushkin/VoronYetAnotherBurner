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

m3_screw_d = [2.6, 3.5];
m3_screw_cap_d = [5.2, 5.6, 7];
m3_screw_cap_h = [3, 0.2];

function m2_5_screw_d(for_cutting = true) = m2_5_screw_d[for_cutting ? 1 : 0];
function m3_screw_d(for_cutting = true) = m3_screw_d[for_cutting ? 1 : 0];

function m2_5_screw_cap_d(for_cutting = true) = m2_5_screw_cap_d[for_cutting ? 1 : 0];
function m3_screw_cap_d(for_cutting = true) = m3_screw_cap_d[for_cutting ? 1 : 0];

function m3_washer_d() = m3_screw_cap_d[2];

function m3_cap_h() = m3_screw_cap_h[0];

function m3_washer_h() = m3_screw_cap_h[1];

//-------------------------------------------------

module mX_screw(cap_d, cap_h, screw_d, screw_l, washer_d = 0, washer_h = 0) {
    if (washer_d != 0 && washer_h != 0) {
        cylinder(d = washer_d, h = washer_h);
        cylinder(d = cap_d, h = cap_h + washer_h);
    } else 
        cylinder(d = cap_d, h = cap_h);
    
    translate([0, 0, -screw_l])
        cylinder(d = screw_d, h = screw_l + eps);
}

module mX_screw_(length, cap_h, screw_sizes, cap_sizes, for_hole_cutting, with_washer) {
    i = for_hole_cutting ? (with_washer ? 2 : 1) : 0;
    if (with_washer)
        mX_screw(cap_sizes[i], cap_h[0], screw_sizes[i], length, cap_sizes[2], cap_h[1]);
    else
        mX_screw(cap_sizes[i], cap_h[0], screw_sizes[i], length);
}

module m3_screw(length, for_hole_cutting = true, with_washer = false) {
    mX_screw_(length, m3_screw_cap_h, m3_screw_d, m3_screw_cap_d, for_hole_cutting, with_washer);
}

