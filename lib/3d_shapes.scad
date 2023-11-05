// 3d_shapes.scad -- contains auxiliary functions needed to work with 3D objects */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

use <MCAD/boxes.scad>

use <2d_shapes.scad>

eps = 0.004;

// supports negative sizes
module uncentered_rounded_box(coords, rounding, centerX = false, centerY = false, centerZ = false, sidesonly = true) {
    translate([
        centerX ? 0 : (coords[0] / 2),
        centerY ? 0 : (coords[1] / 2),
        centerZ ? 0 : (coords[2] / 2)
    ])
        roundedBox([abs(coords.x), abs(coords.y), abs(coords.z)], rounding, sidesonly = sidesonly);
}

// supports negative sizes
module centered_rounded_box(coords, rounding, centerX = true, centerY = true, centerZ = true, sidesonly = true) {
    uncentered_rounded_box(coords, rounding, centerX, centerY, centerZ, sidesonly);
}

// supports negative sizes
module uncentered_box(coords, centerX = false, centerY = false, centerZ = false) {
    translate([
        centerX ? (-abs(coords.x) / 2) : (coords.x > 0 ? 0 : coords.x),
        centerY ? (-abs(coords.y) / 2) : (coords.y > 0 ? 0 : coords.y),
        centerZ ? (-abs(coords.z) / 2) : (coords.z > 0 ? 0 : coords.z)
    ])
        cube([abs(coords.x), abs(coords.y), abs(coords.z)]);
}

// supports negative sizes
module centered_box(coords, centerX = true, centerY = true, centerZ = true) {
    uncentered_box(coords, centerX, centerY, centerZ);
}

module angle_rounding(r, h, angle = 90, center = false, eps = eps, fromX = true) {
    linear_extrude(height = h, center = center)
        angle_rounding_2d(r, angle, eps, fromX);
}

module disc(outer_d = -1, h, center = true, outer_r = -1) {
    assert(outer_d != -1 || outer_r != -1, "Either d or r must be specified");
    assert(outer_d == -1 || outer_r == -1, "Both d and r cannot be specified together");

    d = outer_d == -1 ? outer_r * 2 : outer_d;
    cylinder(d = d - h, h = h, center = center);

    translate([0, 0, center ? 0 : h / 2])
        rotate_extrude()
            translate([d / 2 - h / 2, 0])
                circle(d = h, $fn = h * 4);
}

