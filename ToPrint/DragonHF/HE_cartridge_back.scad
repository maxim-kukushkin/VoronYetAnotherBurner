// HE_cartridge_back.scad -- contains the model of the back part of DragonHF hotend cartridge of YetAnotherBurner */
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

use <../../lib/2d_shapes.scad>
use <../../lib/3d_shapes.scad>
use <../../lib/screws.scad>
use <../../lib/heat_inserts.scad>
use <../../lib/bezier.scad>
use <../../lib/path_extrude_2d.scad>

use <../../models/DragonHF_Hotend.scad>

use <../../common.scad>

depth = HE_cartridge_back_depth();

back_thickness = 1.7;
front_thickness = 10;

function HE_catridge_hook_thickness() = 2;

cooling_fan_channel_dots = Bezier([
    [-HE_cartridge_cooler_wire_ch_offset(), -depth - eps],
    LINE(),
    LINE(),
    [-HE_cartridge_cooler_wire_ch_offset(), -depth + 1],
    OFFSET([0, 15]),
    OFFSET([0, -15]),
    [-5, -1],
    LINE(),
    LINE(),
    [-5, eps]
]);

HE_cartridge_back();

module HE_cartridge_back() {
    color(parts_color()) {
        difference() {
            union() {
                uncentered_box([HE_cartridge_w(), -depth, -HE_cartridge_h()], centerX=true);
                for (i = [-1, 1])
                    translate([i* HE_cartridge_w() / 2, 0, 0])
                        uncentered_box([
                            -i * ((HE_cartridge_w() - bottom_mount_screw_dist()) / 2 + m3_screw_d() / 2 + 2),
                            -depth,
                            -HE_cartridge_outer_h()
                        ]);
                
                for (i = [-1, 1])
                    translate([i * top_holding_screw_dist() / 2, 0, 0])
                        rotate([90, 0, 0])
                            _screw_hook();
            }
            
            _main_vent_shaft();
            _side_vents();
            _heatsink_shaft();
            _heatsink_interface();
            _mounting_screw_holes();
            _front_part_mount_heat_insert_slots();
            _cooling_duct_mount_heat_insert_slots();
            _blower_wire_channels();
            _cooling_fan_wire_channel();
        }

        _wire_holders();
    }
}

//!_screw_hook();
module _screw_hook() {
    w = 2;
    ext = 0.5;

    total_w = m3_screw_d() + w * 2;
    
    linear_extrude(height = HE_catridge_hook_thickness()) {
        difference() {
            translate([0, -eps])
                centered_square([total_w, HE_cartridge_top_offset() + eps], centerY=false);
            translate([0, HE_cartridge_top_offset()])
                circle(d = m3_screw_d(), $fn=20);
        }
        
        for (i = [-1, 1])
            translate([i * (total_w / 2 - w / 2), HE_cartridge_top_offset() - eps]) {
                centered_square([w, ext + eps], centerY=false);
                
                translate([0, ext + eps])
                    circle(d = w, $fn=20);
            }
        
        translate([total_w / 2, 0])
            smooth_right_angle_2d(1, 1);
        translate([-total_w / 2, 0])
            rotate(90)
                smooth_right_angle_2d(1, 1);
    }
}

module _main_vent_shaft() {
    translate([0, eps, -HE_cartridge_roof_h() - HE_cartridge_slot_h() - HE_cartridge_vent_h() / 2])
        rotate([90, 0, 0])
            centered_rounded_box(
                [HE_cartridge_vent_w(), HE_cartridge_vent_h(), depth + 2 * eps],
                HE_cartridge_vent_shaft_rounding(),
                centerZ=false);
}

module _side_vents() {
    w = depth - back_thickness - front_thickness;
    translate([
        0,
        -back_thickness - w / 2,
        -HE_cartridge_roof_h() - HE_cartridge_slot_h() - HE_cartridge_vent_h() / 2])
        rotate([0, 90, 0])
            centered_rounded_box([HE_cartridge_vent_h(), w, HE_cartridge_w() + 2 * eps], 2);
}

module _heatsink_shaft() {
    translate([0, -depth, -HE_cartridge_roof_h()])
        rotate([180, 0, 0])
            cylinder(d = HE_cartridge_vent_w(), h = HE_cartridge_h());
}

module _heatsink_interface() {
    translate([0, -depth, eps]) {
        // PTFE shaft
        rotate([180, 0, 0])
            cylinder(d = PTFE_shaft_cut_d(), h = HE_cartridge_roof_h() + 2 * eps);
     
        // m2.5 holder screws
        for (i = [0, 1])
            rotate([0, 0, 45 + i*90])
                translate([hotend_screw_offset(), 0, 0])
                    rotate([180, 0, 0]) {
                        cylinder(d = m2_5_screw_d(), h = HE_cartridge_roof_h() + 2 * eps);
                        cylinder(d = m2_5_screw_cap_d(), h = HE_cartridge_roof_h() - HE_cartridge_slot_h() - HE_cartridge_screw_h());
                    }
    }
}

module _mounting_screw_holes() {
    for (i = [-1, 1])
        translate([i * bottom_mount_screw_dist() / 2, eps, HE_cartridge_top_offset() - bottom_mount_screw_z_offset()])
            rotate([90, 0, 0])
                cylinder(d = m3_screw_d(), h = depth + 2 * eps, $fn=30);
}

module _front_part_mount_heat_insert_slots() {
    for (i = [-1, 1])
        translate([
            i * HE_cartridge_common_screw_dist() / 2,
            -depth - eps,
            -HE_cartridge_common_screw_offset_z()
        ])
            rotate([-90, 0, 0]) {
                cylinder(d = m3_heat_insert_d(), h = 5, $fn=30);
            }
}

module _cooling_duct_mount_heat_insert_slots() {
    for (i = [-1, 1])
        translate([
            i * HE_cartridge_w() / 2,
            -depth + cooling_duct_mount_screw_offset_y(),
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

module _cooling_fan_wire_channel() {
    translate([0, 0, -HE_cartridge_cooler_wire_ch_depth()])
        linear_extrude(height = HE_cartridge_cooler_wire_ch_depth() + eps)
            path_extrude_2d(HE_cartridge_cooler_wire_ch_w(), cooling_fan_channel_dots);
}

module _wire_holders() {
    ch_w = HE_cartridge_cooler_wire_ch_w() / 2;

    // offset percentage, right/left
    set = [[10, 1], [50, -1], [90, 1]];

    normals = path_extrude_2d_normals(cooling_fan_channel_dots);

    for (wh = set) {
        n = (len(cooling_fan_channel_dots) - 1) * wh[0] / 100;
        dot = cooling_fan_channel_dots[n];
        normal = normals[n];
        translate([dot.x + ch_w * cos(normal - wh[1] * 90), dot.y + ch_w * sin(normal - wh[1] * 90)])
            rotate(normal - 90 + wh[1] * 90)
                _wire_holder();
                
    }
}

module _wire_holder() {
    dots = Bezier([
        [-HE_cartridge_cooler_wire_ch_holder_l() / 2, -1],
        LINE(),
        LINE(),
        [-HE_cartridge_cooler_wire_ch_holder_l() / 2, 0], 
        OFFSET([1, 0]),
        OFFSET([-1, 0]),
        [0, HE_cartridge_cooler_wire_ch_holder_w()]
    ]);

    rotate([0, 180, 0])
        linear_extrude(height = HE_cartridge_cooler_wire_ch_holder_h())
            polygon(concat(dots, [for (d = reverse(dots)) [-d.x, d.y]]));
}
