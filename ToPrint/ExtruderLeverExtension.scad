// ExtruderLeverExtension.scad -- contains the model of the Extruder Lever Extension part of YetAnotherBurner */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

$fs = 1;
$fa = 0.4;

eps = 0.004;

use <../common.scad>

use <../models/BondTech_LGX_Lite.scad>
use <../lib/2d_shapes.scad>
use <../lib/3d_shapes.scad>

lever_length = 6.5;
length = 25;
wall = 1.2;

inner_w = tension_lever_w() + 0.3;
outer_w = 2 * wall + inner_w;

function lever_extension_thickness() = 2 * wall + tension_lever_thickness();

ExtruderLeverExtension();

module ExtruderLeverExtension() {
    color(parts_color()) {
        difference() {
            linear_extrude(height = lever_extension_thickness(), center = true) {
                l = length - outer_w / 2;
                centered_square([outer_w, l], centerY = false);
                translate([0, l])
                    circle(d = outer_w);
            }

            translate([0, -eps, 0])
               centered_box([inner_w, lever_length, tension_lever_thickness() + 0.4], centerY=false); 
        }

        translate([0, 10, lever_extension_thickness() / 2 - eps])
            cylinder(d = outer_w, h = 1.5);
    }
}
