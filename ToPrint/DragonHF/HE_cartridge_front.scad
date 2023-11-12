// HE_cartridge_front.scad -- contains the model of the front part of DragonHF hotend cartridge of YetAnotherBurner */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/


include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/fans.scad>

$fs = 1;
$fa = 0.4;

eps = 0.004;

use <../../lib/2d_shapes.scad>
use <../../lib/3d_shapes.scad>
use <../../lib/screws.scad>
use <../../lib/heat_inserts.scad>
use <../../lib/bezier.scad>

use <../../models/DragonHF_Hotend.scad>

use <../../common.scad>

HE_cartridge_front();

function cooling_fan_d() = fan_bore(fan40x11);
function cooling_fan_screw_dist() = 32;
function HE_cartridge_fan_offset_z() = HE_cartridge_h() - HE_fan_to_bottom_offset() - fan_width(fan40x11) / 2;
fan_center_z = -HE_cartridge_fan_offset_z();

depth = HE_cartridge_front_depth();

front_part_depth = depth - (extruder_mount_w() - extruder_mount_shaft_offset()) - 4; 

function front_part_h_diff() = (fan_center_z + fan_width(fan40x11) / 2);
function front_part_h() = HE_cartridge_h() + front_part_h_diff();

accelerometer_bottom_offset = 1;
accelerometer_front_offset = 1;
accelerometer_center_offset_yz = [
    depth - accelerometer_front_offset - accelerometer_w() + accelerometer_screw_side_offset(),
    HE_cartridge_outer_h() - accelerometer_bottom_offset - accelerometer_l() / 2
];

function accelerometer_location() = [
    HE_cartridge_front_location().x + HE_cartridge_w() / 2,
    HE_cartridge_front_location().y - accelerometer_center_offset_yz[0],
    HE_cartridge_front_location().z - accelerometer_center_offset_yz[1]
];

module HE_cartridge_front() {
    color(parts_color()) {
        difference() {
            union() {
                main_body();

                // Extenstions for 50mm bottom screws
                for (i = [-1, 1])
                    translate([i * HE_cartridge_w() / 2, 0, 0])
                        uncentered_box([
                            -i * ((HE_cartridge_w() - bottom_mount_screw_dist()) / 2 + m3_screw_d() / 2 + 2),
                            -depth,
                            -HE_cartridge_outer_h()
                        ]);
            }

            _hotend_shaft();
            _hotend_holes();
            _mounting_screw_holes();

            _vent_shaft();

            _fan_mount_holes();
            _extruder_mount_holes();
            _back_mount_screw_holes();
            _cooling_duct_mount_holes();
            _accelerometer_mount_holes();

            _blower_wire_channels();
            _cooling_fan_wire_channel();
        }

        _wire_holders();
    }
}

module main_body() {
    rotate([90, 0, 90])
        translate([-depth, -HE_cartridge_h()])
            linear_extrude(height = HE_cartridge_w(), center = true) {
                square([depth, HE_cartridge_h()]);
                square([front_part_depth, front_part_h()]);
            }
}

module _mounting_screw_holes() {
    for (i = [-1, 1])
        translate([
            i * bottom_mount_screw_dist() / 2,
            -depth - eps,
            -bottom_mount_screw_z_offset() + HE_cartridge_top_offset()
        ])
            rotate([-90, 0, 0]) {
                cylinder(d = m3_screw_d(), h = depth + 2 * eps, $fn=30);
                cylinder(d = m3_screw_cap_d(), h = m3_cap_h() - 0.3);
            }
}

module _hotend_holes() {
    translate([0, 0, eps]) {
        // PTFE shaft
        rotate([180, 0, 0])
            cylinder(d = PTFE_shaft_cut_d(), h = HE_cartridge_roof_h() + 2 * eps);
     
        // m2.5 holder screws
        for (i = [0, 1])
            rotate([0, 0, -45 - i*90])
                translate([hotend_screw_offset(), 0, 0])
                    rotate([180, 0, 0]) {
                        cylinder(d = m2_5_screw_d(), h = HE_cartridge_roof_h() + 2 * eps);
                        cylinder(d = m2_5_screw_cap_d(), h = HE_cartridge_roof_h() - HE_cartridge_slot_h() - HE_cartridge_screw_h());
                    }
    }
}

module _hotend_shaft() {
    translate([0, 0, -HE_cartridge_roof_h()])
        rotate([180, 0, 0])
            cylinder(d = HE_cartridge_vent_w(), h = HE_cartridge_h());
}

module _vent_shaft() {
    hull() {
        translate([0, -depth - 0.1, fan_center_z])
            rotate([-90, 0, 0])
                cylinder(d = cooling_fan_d(), h = 0.1);

        translate([0, -hotend_heatsink_d() / 2, -HE_cartridge_roof_h() - HE_cartridge_slot_h()])
            rotate([-90, 0, 0])
                uncentered_rounded_box(
                    [HE_cartridge_vent_w(), HE_cartridge_vent_h(), 0.1],
                    HE_cartridge_vent_shaft_rounding(),
                    centerX=true);
    }

    translate([0, -hotend_heatsink_d() / 2, -HE_cartridge_roof_h() - HE_cartridge_slot_h() - HE_cartridge_vent_h() / 2])
        rotate([-90, 0, 0])
            centered_rounded_box(
                [HE_cartridge_vent_w(), HE_cartridge_vent_h(), hotend_heatsink_d()],
                HE_cartridge_vent_shaft_rounding(),
                centerZ=false);
}

module _fan_mount_holes() {
    HE_cartridge_front_for_each_fan_screw_pos()
        translate([0, -eps, 0])
            rotate([-90, 0, 0])
                cylinder(d = m3_heat_insert_d(), h = 5 + eps);
}

module _extruder_mount_holes() {
    for (i = [-1, 1])
        translate([i * extruder_mount_screw_dist() / 2, extruder_mount_shaft_offset() - extruder_mount_w() / 2, eps])
            rotate([180, 0, 0])
                cylinder(d = m3_heat_insert_d(), h = 5 + eps);
}

module _back_mount_screw_holes() {
    HE_cartridge_front_for_each_backmount_screw_pos()
        rotate([-90, 0, 0]) {
            cylinder(d = m3_screw_d(), h = depth + 2 * eps, $fn=30);
            cylinder(d = m3_screw_cap_d(), h = m3_cap_h() - 0.3);
        }
}

module _cooling_duct_mount_holes() {
    for (i = [-1, 1])
        translate([
            i * HE_cartridge_w() / 2,
            -cooling_duct_mount_screw_offset_y(),
            -(HE_cartridge_location().z - right_blower_location().z + cooling_duct_mount_screw_offset_z())])
            rotate([0, 0, (i - 1) * 90])
                m3_insert_vertical_hole(0);
}

module _blower_wire_channels() {
    for (i = [0, 1])
        mirror([i, 0, 0])
            translate([
                HE_cartridge_w() / 2 - HE_cartridge_blower_wire_ch_depth(),
                eps,
                -HE_cartridge_blower_wire_ch_offset_z()
            ])
                uncentered_box([
                    HE_cartridge_blower_wire_ch_depth() + eps,
                    -depth - 2 * eps,
                    HE_cartridge_blower_wire_ch_width()
                ],
                centerZ=true);
}

//!_cooling_fan_wire_channel();
module _cooling_fan_wire_channel() {
    l = depth - front_part_depth; 
    cut_depth = HE_cartridge_cooler_wire_ch_depth();

    translate([-HE_cartridge_cooler_wire_ch_offset(), 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = HE_cartridge_cooler_wire_ch_w(), center = true) {
                translate([eps, eps])
                    uncentered_square([-(l - cut_depth + eps), -(cut_depth + eps)]);
                translate([-(l - cut_depth), 0])
                    rotate(180)
                        smooth_right_angle_2d(cut_depth, cut_depth);
            }
}

module _wire_holders() {
    ch_offset = HE_cartridge_cooler_wire_ch_offset();
    ch_w = HE_cartridge_cooler_wire_ch_w();

    // offset percentage, left/right
    set = [[10, -1], [40, 1], [70, -1]];
    for (wh = set)
        translate([-ch_offset + wh[1] * ch_w / 2, - (depth - front_part_depth) * wh[0] / 100])
            rotate(wh[1] * 90)
                _wire_holder();
}

//!_wire_holder();
module _wire_holder() {
    dots = Bezier([
        [-HE_cartridge_cooler_wire_ch_holder_l() / 2, -eps], 
        OFFSET([1, 0]),
        OFFSET([-1, 0]),
        [0, HE_cartridge_cooler_wire_ch_holder_w()]
    ]);

    rotate([0, 180, 0])
        linear_extrude(height = HE_cartridge_cooler_wire_ch_holder_h())
            polygon(concat(dots, [for (d = reverse(dots)) [-d.x, d.y]]));
}

module _accelerometer_mount_holes() {
    for_each_accelerometer_screw_pos()
        m2_insert_vertical_hole(0);
}

module HE_cartridge_front_for_each_fan_screw_pos(top_only = false, bottom_only = false) {
    assert(!(top_only && bottom_only), "top_only and bottom_only flags are mutually exclusive");
    pitch = fan_hole_pitch(fan40x11);
    translate([0, -depth, fan_center_z])
        for (x = [-1, 1])
            for (z = top_only ? [1] : (bottom_only ? [-1] : [-1, 1]))
                translate([x * pitch, 0, z * pitch])
                    children();
}

module HE_cartridge_front_for_each_backmount_screw_pos() {
    for (i = [-1, 1])
        translate([
            i * HE_cartridge_common_screw_dist() / 2,
            -depth - eps,
            -HE_cartridge_common_screw_offset_z()
        ])
            children();
}

module for_each_accelerometer_screw_pos() {
    translate([HE_cartridge_w() / 2, -accelerometer_center_offset_yz[0], -accelerometer_center_offset_yz[1]])
        for (i = [-1, 1])
            translate([0, 0, i * accelerometer_screw_dist() / 2])
                children();
}
