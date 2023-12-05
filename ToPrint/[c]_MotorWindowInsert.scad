// [c]_MotorWindowInsert.scad -- contains the model of the Motor Window Insert part of YetAnotherBurner */
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

MotorWindowInsert(for_stl_export = true);

module MotorWindowInsert(for_stl_export = false) {
    inner_d = motor_body_d() + 0.3;
    color([0.8, 0.8, 0.8, 0.7])
        rotate([for_stl_export ? 180 : -90, 0, 0]) {
            linear_extrude(height = cover_front_plate_thickness() + eps)
                difference() {
                    circle(d = motor_body_d() + 2 * cover_motor_insert_w() + 0.1);
                    circle(d = inner_d);
                }

            translate([0, 0, cover_front_plate_thickness()])
                linear_extrude(height = 5)
                    difference() {
                        circle(d = motor_body_d() + 2 * cover_motor_insert_inner_w());
                        circle(d = inner_d);
                    }
        }
}
