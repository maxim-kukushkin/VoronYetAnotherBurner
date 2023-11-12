// CoolingDuct_x2.scad -- contains the model of the Cooling Duct part of YetAnotherBurner */
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

use <../lib/screws.scad>
use <../lib/2d_shapes.scad>
use <../lib/3d_shapes.scad>
use <../lib/bezier.scad>
use <../lib/path_extrude.scad>
use <../models/DragonHF_Hotend.scad>

blower_shaft_h = 4;
blower_shaft_wall = 0.8;

mount_loop_h = 3;

mount_w = blower_shaft_outer_w() + 2 * blower_wall();

shaft_inner_l = blower_shaft_outer_l() - 2 * blower_shaft_wall;
shaft_inner_w = blower_shaft_outer_w() - 2 * blower_shaft_wall;

duct_wall = blower_wall() + blower_shaft_wall;

vertical_shaft_l = HE_cartridge_outer_h() - (HE_cartridge_location().z - cooling_duct_location().z);

shaft_center_x = blower_fan_offset_x() + mount_w / 2;

nozzle_z = -(cooling_duct_location().z - HE_location().z) - hotend_total_h();
nozzle_x = -cooling_duct_location().x;
        
CoolingDuct();
*translate([nozzle_x, 0, nozzle_z + hotend_total_h()])
    DragonHF_Hotend();

module CoolingDuct() {
    color(parts_color()) {
        _vertical_shaft();
        _blower_shaft();
        _vent();
        
        for (i = [-1, 1])
            translate([0, i * cooling_duct_mount_l() / 2, -cooling_duct_mount_screw_offset_z()])
                mirror([0, i-1, 0])
                    rotate([0, 90, 0])
                        _mounting_loop();

        uncentered_box(
            [
                blower_fan_offset_x() + eps,
                cooling_duct_mount_l(),
                -2 * cooling_duct_mount_screw_offset_z()
            ],
            centerY=true);
    }
}

module _vertical_shaft() {
    translate([shaft_center_x, 0, 0])
        rotate([180, 0, 0])
            linear_extrude(height = vertical_shaft_l -3)
                difference() {
                    centered_square([mount_w, cooling_duct_mount_l()]); 
                    centered_square([shaft_inner_w, shaft_inner_l]);
                }
}

module _blower_shaft() {
    translate([shaft_center_x, 0, 0])
        linear_extrude(height = blower_shaft_h + eps)
            difference() {
                centered_square([blower_shaft_outer_w(), blower_shaft_outer_l()]); 
                centered_square([shaft_inner_w, shaft_inner_l]);
            }
}

//!_mounting_loop();
module _mounting_loop() {
    bezier_dot_num = 20;

    screw_offset = cooling_duct_mount_screw_offset_y() - cooling_duct_mount_l() / 2;

    side_width = m3_screw_cap_d() / 2 + 1;

    dots1 = BezierDots(
        [-cooling_duct_mount_screw_offset_z(), -eps],
        [-cooling_duct_mount_screw_offset_z(), 2],
        [-side_width, screw_offset - 2],
        [-side_width, screw_offset],
        bezier_dot_num);

    all_dots = [
        for (x = dots1) x,
        for (xy = reverse(dots1)) [-xy.x, xy.y]
    ];
    
    linear_extrude(height = mount_loop_h) 
        difference() {
            union() {
                polygon(all_dots);
                translate([0, screw_offset])
                    circle(r = side_width, $fn=30);
            }

            translate([0, screw_offset])
                circle(d = m3_screw_d(), $fn=30);
        }
}

//!_vent();
module _vent() {
    difference() {
        _vent_pipe(size_diff = duct_wall * 2);
        _vent_pipe(len_oversize = 1);
    }
}

//!_vent_pipe();
module _vent_pipe(size_diff = 0, len_oversize = 0) {
    hot_end_offset_x = 18;
    hot_end_offset_z = 5;
    angle = 43;
    duct_bottom_l = 9;
    duct_bottom_w = 4;

    bezier_control_l = 2;
    bottom_z = (nozzle_z + hot_end_offset_z) - len_oversize * sin(angle);
    bottom_x = (nozzle_x + hot_end_offset_x) - len_oversize * cos(angle);
    pipe_points = [
        [shaft_center_x, 0, -vertical_shaft_l],
        [shaft_center_x - 2, 0, -vertical_shaft_l - 10],
        [bottom_x + bezier_control_l * cos(angle), 0, bottom_z + bezier_control_l * sin(angle)],
        [bottom_x, 0, bottom_z]
    ];


    path_extrude(
        [
            [shaft_center_x, 0, -vertical_shaft_l + 3 + len_oversize],
            //[shaft_center_x, 0, -vertical_shaft_l + len_oversize],
            for (p = Bezier(pipe_points, precision = 0.05)) p
        ],
        squarev([shaft_inner_w + size_diff, shaft_inner_l + size_diff]),
        squarev([duct_bottom_w + size_diff * 0.5, duct_bottom_l + size_diff * 0.5]),
        preRotate=true);
}

module cooling_duct_for_each_screw_pos() {
    for (i = [-1, 1])
        translate([mount_loop_h, i * cooling_duct_mount_screw_offset_y(), -cooling_duct_mount_screw_offset_z()])
            children();
}
