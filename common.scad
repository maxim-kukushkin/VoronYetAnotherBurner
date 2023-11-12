// common.scad -- contains all constants and calculations shared among the modules of YetAnotherBurner */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/fans.scad>
include <NopSCADlib/vitamins/blowers.scad>

use <models/DragonHF_Hotend.scad>
use <models/BondTech_LGX_Lite.scad>

use <lib/2d_shapes.scad>
use <lib/screws.scad>
use <lib/heat_inserts.scad>

function extruder_mount_screw_offset() = m3_screw_cap_d() / 2 + 0.5;
function extruder_mount_screw_dist() = extruder_body_length() + extruder_mount_screw_offset() * 2;

function HE_cartridge_location() = [0, 0, -HE_cartridge_top_offset()];
function HE_location() = [0, -20, -18.4];
function HE_cartridge_front_location() = extruder_mount_location();

function HE_cartridge_blower_wire_ch_offset_z() = 6.5;
function HE_cartridge_blower_wire_ch_depth() = 1.5;
function HE_cartridge_blower_wire_ch_width() = 3;

function HE_cartridge_cooler_wire_ch_offset() = 16.5;
function HE_cartridge_cooler_wire_ch_depth() = 4;
function HE_cartridge_cooler_wire_ch_w() = 3;
function HE_cartridge_cooler_wire_ch_holder_h() = 0.8;
function HE_cartridge_cooler_wire_ch_holder_l() = 3;
function HE_cartridge_cooler_wire_ch_holder_w() = 1;
 
function HE_cartridge_roof_h() = HE_cartridge_h() - hotend_heatsink_h();
function HE_cartridge_floor_h() = 4;
function HE_cartridge_slot_h() = 1.5;
function HE_cartridge_screw_h() = 9.5;
function HE_cartridge_w() =
    extruder_mount_screw_dist() + m3_heat_insert_d() + 2 * heat_insert_min_offset();
function HE_cartridge_h() = -HE_location().z - HE_cartridge_top_offset() + hotend_heatsink_h();
function HE_cartridge_depth() = 50 + m3_cap_h() - 4;
function HE_cartridge_bottom_screw_offset() = 2;
function HE_cartridge_outer_h() = HE_cartridge_h() + HE_cartridge_bottom_screw_offset();
function HE_cartridge_top_offset() = 3;

function HE_cartridge_vent_shaft_rounding() = 4;
function HE_cartridge_vent_w() = hotend_heatsink_d() + 0.5;
function HE_cartridge_vent_h() = hotend_heatsink_h() - HE_cartridge_slot_h() - HE_cartridge_floor_h() - 3;
function HE_cartridge_back_depth() = abs(HE_location().y);
function HE_cartridge_front_depth() = HE_cartridge_depth() - HE_cartridge_back_depth();

function HE_cartridge_common_screw_offset_z() = 5 + 2 + m3_screw_d($for_cutting = false) / 2;
function HE_cartridge_common_screw_dist() =
    HE_cartridge_w() - m3_heat_insert_d() - 2 * heat_insert_min_offset() - 3;


function HE_fan_to_bottom_offset() = 4;
function HE_fan_location() = [
    0,
    -HE_cartridge_depth() - fan_depth(fan40x11) / 2,
    -HE_cartridge_h() - HE_cartridge_top_offset() + HE_fan_to_bottom_offset() + fan_width(fan40x11) / 2];

function PTFE_shaft_d() = 4.2;
function PTFE_shaft_cut_d() = 4.5;

function bottom_mount_screw_dist() = 32.5;
function bottom_mount_screw_z_offset() = 43.3;

function top_holding_screw_dist() = 31;

function top_mount_screw_dist() = 32.5;
function top_mount_screw_z_offset() = 8.3;
function top_mount_screw_y_offset() = 7.8;

function extruder_mount_shaft_offset() = extruder_mount_side_wall() + PTFE_shaft_d() / 2;
function extruder_mount_h() = m3_cap_h() + m3_washer_h() + 7;
function extruder_mount_side_wall() = 3;
function extruder_mount_w() =
    extruder_mount_side_wall() + PTFE_shaft_d() / 2 + mounting_screw_to_hole_w_offset2() + m3_washer_d() / 2 + extruder_mount_side_wall();
function extruder_mount_location() =
    [HE_location().x, HE_location().y, HE_cartridge_location().z];
function extruder_mount_loop_w() = m3_screw_d() + 2 * 1.5;
function extruder_mount_vertical_cut_offset() = extruder_mount_loop_w() / 2 + 2;

function extruder_mount_wire_ch_offset() = 4.5;

function extruder_location() =
    [extruder_mount_location().x, extruder_mount_location().y, extruder_mount_location().z + extruder_mount_h()];

function pcb_bracket_backplate_offset_y() = 14;
function pcb_bracket_backplate_thickness() = 7;
function pcb_bracket_backplate_h() = 63;
function pcb_bracket_bottom_mount_thickness() = 5;
function pcb_bracket_rounding() = 2;
function pcb_bracket_location() = [
    extruder_mount_location().x,
    extruder_mount_location().y + extruder_mount_shaft_offset() - extruder_mount_w() / 2,
    extruder_mount_location().z];
function pcb_bracket_side_wall_dist() = extruder_body_length() + 0.7;
function pcb_bracket_side_wall_thickness() = (HE_cartridge_w() - pcb_bracket_side_wall_dist()) / 2;

function pcb_bracket_cover_mount_screw_offset_z() = 4;
function pcb_bracket_cover_mount_screw_offset_y() = 5;

function blower_fan_offset_x() = 1.2;
function blower_fan_offset_z() = 8;
function right_blower_intake_w() = blower_bore(RB5015) - 2;
function right_blower_intake_depth() = 2;
function blower_axis_z_offset() = blower_axis(RB5015).y;
function blower_axis_y_offset() = blower_axis(RB5015).x;

function left_blower_location() = [
    -HE_cartridge_w() / 2 - blower_fan_offset_x(),
    extruder_mount_location().y + blower_exit(RB5015) / 2,
    extruder_mount_location().z - blower_fan_offset_z()
];
function right_blower_location() = [
    HE_cartridge_w() / 2 + blower_fan_offset_x() + blower_depth(RB5015),
    extruder_mount_location().y + blower_exit(RB5015) / 2,
    extruder_mount_location().z - blower_fan_offset_z()
];

function drag_chain_w() = 17.2;
function drag_chain_location() = [0, 38, 43.3];
function drag_chain_screw_dist() = 8;
function drag_chain_screw_offset() = 4;

function drag_chain_holder_thickness() = m3_heat_insert_d() + 2 * heat_insert_min_offset();
function drag_chain_holder_screw_dist() = 30;
function drag_chain_holder_location() = [
    0,
    pcb_bracket_location().y + pcb_bracket_backplate_offset_y() + pcb_bracket_backplate_thickness(),
    pcb_bracket_location().z + pcb_bracket_backplate_h() - drag_chain_holder_thickness() / 2
];

function cooling_duct_location() = [
    HE_cartridge_w() / 2,
    HE_location().y,
    right_blower_location().z
];

function blower_shaft_outer_l() = 17;
function blower_shaft_outer_w() = 12.4;
function blower_wall() = 1.24;
function cooling_duct_mount_screw_offset_z() = m3_screw_cap_d() / 2 + 2;
function cooling_duct_mount_l() = blower_shaft_outer_l() + 2 * blower_wall();
function cooling_duct_mount_screw_offset_y() = cooling_duct_mount_l() / 2 + m3_screw_cap_d() / 2 + 0.5;


function accelerometer_w() = 16;
function accelerometer_l() = 20;
function accelerometer_h() = 1.56;
function accelerometer_screw_dist() = 15;
function accelerometer_screw_side_offset() = 2.4;

function cooling_fan_depth() = 11;
function cooling_fan_side() = fan_width(fan40x11);

function cover_top_plate_thickness() = 2;
function cover_front_plate_thickness() = 4;
function cover_split_offset() = 18;
function cover_join_screw_dist() = 25;
function cover_front_mount_screw_offset() = 6;

function cover_color() = "#3333FF";
//function parts_color() = "green";
function parts_color() = "#555555";

function cover_motor_insert_w() = 1;
function cover_motor_insert_inner_w() = 2;

function cover_led_wire_hole_offset() = 10;
function cover_led_wire_hole_side() = 3;

function top_cover_location() = [
    HE_location().x,
    HE_location().y,
    HE_cartridge_location().z + pcb_bracket_backplate_h()
];

function front_cover_location() = [
    top_cover_location().x,
    top_cover_location().y - cover_split_offset(),
    top_cover_location().z
];

module cover_rounded_profile(width, rounding) {
    difference() {
        union() {
            centered_square([width - rounding * 2, rounding * 2]);
            for (i = [-1, 1])
                translate([i * (width / 2 - rounding), 0])
                    circle(r = rounding, $fn=20);
        }

        centered_square([width * 2, -rounding * 2], centerY=false);
    }
}

function motor_window_insert_location() = [
    extruder_location().x,
    HE_cartridge_front_location().y - HE_cartridge_front_depth() - cooling_fan_depth() - cover_front_plate_thickness(),
    extruder_location().z + motor_offset_z()
];
