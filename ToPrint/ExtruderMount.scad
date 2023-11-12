// ExtruderMount.scad -- contains the model of the Extruder Mount part of YetAnotherBurner */
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
use <../lib/screws.scad>

body_l = extruder_body_length();

loop_w = extruder_mount_loop_w();

wire_ch_w = 3;
wire_ch_depth = 5;

function extruder_mount_screw_y_offset() = extruder_mount_w() / 2 - extruder_mount_shaft_offset();

ExtruderMount();

module ExtruderMount() {
    color(parts_color()) {
        difference() {
            _motor_mount_main_body();
            
            _extruder_screw_caps();
            _pcb_bracket_mount_cuts();
            _wire_channel();
        }

        _wire_fixers();
    }
}

module _motor_mount_main_body() {
    linear_extrude(height = extruder_mount_h())
        difference() {
            union() {
                // main body
                translate([0, -extruder_mount_screw_y_offset() - extruder_mount_w() / 2])
                    centered_rounded_square([body_l, extruder_mount_w()], 2, centerY=false);
                
                // mounting loops
                translate([0, -extruder_mount_screw_y_offset()])
                    for (a = [0, 180])
                        rotate(a)
                            translate([body_l / 2, 0]) {
                                translate([-eps, 0])
                                    centered_square([extruder_mount_screw_offset(), loop_w], centerX=false);
                                translate([extruder_mount_screw_offset(), 0])
                                    circle(d = loop_w);
                                translate([0, -loop_w / 2])
                                    rotate(-90)
                                        smooth_right_angle_2d(extruder_mount_screw_offset(), extruder_mount_screw_offset());
                                translate([0, loop_w / 2])
                                        smooth_right_angle_2d(extruder_mount_screw_offset(), extruder_mount_screw_offset());
                            }
            }
            
            // Filament shaft
            circle(d = PTFE_shaft_cut_d());
            
            // Extruder mounting holes
            _for_each_extruder_mount_screw_2d_pos() 
                        circle(d = m3_screw_d());
           
            // mounting loop screw holes
            for (i = [-1, 1])
                translate([i * extruder_mount_screw_dist() / 2, -extruder_mount_screw_y_offset()])
                    circle(d = m3_screw_d());
        }
}

module _extruder_screw_caps() {
    for_each_extruder_mount_screw_pos()
        rotate([180, 0, 0])
            cylinder(d = m3_screw_cap_d(), h = extruder_mount_h()); 
}

module _pcb_bracket_mount_cuts() {
    for (i = [-1, 1])
        translate([i * body_l / 2, 0, -eps])
            uncentered_box(
                [
                    i * (extruder_mount_screw_offset() + loop_w + eps),
                    extruder_mount_w() * 2, // just big enough to cover the full width
                    eps + pcb_bracket_bottom_mount_thickness()
                ],
                centerY=true);
}

module _wire_channel() {
    translate([-extruder_mount_wire_ch_offset(), 0, -eps])
        centered_box([wire_ch_w, 2 * extruder_mount_w(), eps + wire_ch_depth], centerZ=false);
}

module _wire_fixers() {
    sphere_r = 1;
    translate([-extruder_mount_wire_ch_offset(), -extruder_mount_screw_y_offset(), sphere_r])
        for(i = [-1, 1], j = [-1, 1])
            translate([i * wire_ch_w / 2, j * (extruder_mount_w() / 2 - sphere_r), 0])
                sphere(r = sphere_r, $fn=20);
}

module _for_each_extruder_mount_screw_2d_pos() {
    for (i = [-1, 1])
        for (y_o = [mounting_screw_to_hole_w_offset1(), mounting_screw_to_hole_w_offset2()])
            translate([i * mounting_screw_to_hole_l_offset(), -y_o])
                children();
}

module for_each_extruder_mount_screw_pos() {
    _for_each_extruder_mount_screw_2d_pos()
        translate([0, 0, m3_cap_h() + 0.5])
            children();
}
