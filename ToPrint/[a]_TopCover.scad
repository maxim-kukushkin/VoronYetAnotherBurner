// [a]_TopCover.scad -- contains the model of the Top Cover part of YetAnotherBurner */
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

use <../lib/2d_shapes.scad>
use <../lib/3d_shapes.scad>
use <../lib/heat_inserts.scad>
use <../lib/screws.scad>
use <../models/BondTech_LGX_Lite.scad>
use <ExtruderLeverExtension.scad>

pcb_bracket_offset = top_cover_location().y - pcb_bracket_location().y;

width = HE_cartridge_w();
length = cover_split_offset() +
    (
        (pcb_bracket_backplate_offset_y() + pcb_bracket_backplate_thickness()) -
        pcb_bracket_offset);

wall = 5;

TopCover(for_stl_export = true);

module TopCover(for_stl_export = false) {
    color(cover_color()) {
        rotate([for_stl_export ? 90 : 0, 0, 0])
        difference() {
            union() {
                _top_lid();
                _front_heat_insert_panel();
                _side_mount_holders();
                _side_walls();
            }

            _join_insert_holes();
            _ptfe_tube_hole();
            _extruder_lever_cut();
            _right_blower_intake();
        }
    }
}

//!_top_lid();
module _top_lid() {
    thickness = cover_top_plate_thickness();
    rotate([90, 0, 0])
        translate([0, 0, -(length - cover_split_offset())]) 
            difference() {
                linear_extrude(height = length)
                    cover_rounded_profile(width, thickness);

                for (i = [-1, 1])
                    translate([i * width / 2, 0])
                        mirror([i + 1, 0, 0])
                            rotate([90, 0, 0])
                                angle_rounding(thickness, thickness * 3, center=true, $fn=20);

                translate([0, thickness, 0])
                    rotate([90, 0, -90])
                        angle_rounding(thickness, width * 2, center=true, $fn=20);
            }
}

module _front_heat_insert_panel() {
    panel_h = cover_front_mount_screw_offset() * 2 - cover_top_plate_thickness();
    translate([0, -cover_split_offset(), eps])
        uncentered_box([width, 6, -(eps + panel_h)], centerX=true);
}

module _join_insert_holes() {
    top_cover_for_each_join_insert_pos()
        rotate([0, 0, -90])
            m3_insert_vertical_hole(0);
}

module top_cover_for_each_join_insert_pos() {
    for (i = [-1, 1])
        translate([
            i * cover_join_screw_dist() / 2,
            -cover_split_offset(),
            cover_top_plate_thickness() - cover_front_mount_screw_offset()
        ])
            children();
}

module _ptfe_tube_hole() {
    translate([0, 0, -eps])
        cylinder(d = PTFE_shaft_cut_d(), h = cover_top_plate_thickness() + 2 * eps);
}

module _extruder_lever_cut() {
    translate([0, -tension_lever_w_offset(), -eps])
        centered_box([30, lever_extension_thickness() + 0.6, cover_top_plate_thickness() + 2 * eps], centerZ=false);
}

y_tolerance = 0.2;
module _side_mount_holders() {
    height = pcb_bracket_cover_mount_screw_offset_z() + m3_heat_insert_d() / 2 + heat_insert_min_offset();

    right_w = pcb_bracket_cover_mount_screw_offset_y() - y_tolerance;
    left_w = m3_heat_insert_d() / 2;

    for (i = [-1, 1])
        mirror([i + 1, 0, 0])
            translate([-(width / 2 - pcb_bracket_side_wall_thickness() - 0.1), length - cover_split_offset() - pcb_bracket_backplate_thickness() - y_tolerance])
                rotate([90, 0, 90])
                    difference() {
                        linear_extrude(height = 6) {
                            l = left_w + right_w;
                            translate([0, eps])
                                uncentered_square([-l, -height - eps]);
                            polygon([[-l + eps, eps], [-l, -height], [-l - height * 0.7, eps]]);
                        }

                        translate([-right_w, -pcb_bracket_cover_mount_screw_offset_z(), -eps])
                            cylinder(d = m3_heat_insert_d(), h = 5);
                    }
}

//!_side_mount_holder();
module _side_mount_holder() {
    height = pcb_bracket_cover_mount_screw_offset_z() + m3_heat_insert_d() / 2 + heat_insert_min_offset();
    right_w = pcb_bracket_cover_mount_screw_offset_y() - y_tolerance;
    left_w = m3_heat_insert_d() / 2;


    difference() {
        linear_extrude(height = 6) {
            l = left_w + right_w;
            translate([0, eps])
                uncentered_square([-l, -height - eps]);
            polygon([[-l + eps, eps], [-l, -height], [-l - height * 0.7, eps]]);
        }

        translate([-right_w, -pcb_bracket_cover_mount_screw_offset_z(), -eps])
            cylinder(d = m3_heat_insert_d(), h = 5);
    }
}

module top_cover_for_each_bracket_join_pos() {
    for (i = [-1, 1])
        mirror([i + 1, 0, 0])
            translate([
                width / 2 - pcb_bracket_side_wall_thickness() - 0.1,
                pcb_bracket_backplate_offset_y() - pcb_bracket_offset - pcb_bracket_cover_mount_screw_offset_y(),
                -pcb_bracket_cover_mount_screw_offset_z()
            ])
                children();
}

module _side_walls() {
    extruder_mount_gap_l = m3_washer_d() / 2 + 1;
     
    for (i = [-1, 1])
        mirror([i + 1, 0, 0])
            difference() {
                translate([-width / 2, -cover_split_offset(), eps])
                    uncentered_box([
                        wall,
                        cover_split_offset() - pcb_bracket_offset + extruder_mount_vertical_cut_offset() - 0.1,
                        -pcb_bracket_backplate_h()
                    ]);

                translate([-width / 2 - eps, -pcb_bracket_offset - extruder_mount_gap_l, -pcb_bracket_backplate_h() - eps ])
                    uncentered_box([
                        wall + 2 * eps,
                        length, // just long enough cut
                        extruder_mount_h() + m3_cap_h() + m3_washer_h() + 0.5
                    ]);
            }
}

module _right_blower_intake() {
    axis_z = -pcb_bracket_backplate_h() - blower_fan_offset_z() + blower_axis_z_offset();
    translate([
        width / 2 + eps,
        -cover_split_offset() - eps,
        axis_z + right_blower_intake_w() / 2 + 1
    ])
        uncentered_box([-wall - 2 * eps, length, -pcb_bracket_backplate_h()]);
}
