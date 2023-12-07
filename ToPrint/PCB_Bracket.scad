// PCB_Bracket.scad -- contains the model of the PCB Bracket part of YetAnotherBurner */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/blowers.scad>

$fs = 1;
$fa = 0.4;

eps = 0.004;

use <../common.scad>

use <../models/BondTech_LGX_Lite.scad>
use <../models/LDO_Toolhead_PCB.scad>
use <../lib/2d_shapes.scad>
use <../lib/3d_shapes.scad>
use <../lib/screws.scad>
use <../lib/heat_inserts.scad>

width = HE_cartridge_w();

pcb_top_offset = drag_chain_holder_thickness() + 0.5;

back_mount_pillar_side = 8.5;

function th_pcb_location() = [
    pcb_bracket_location().x,
    pcb_bracket_location().y + pcb_bracket_backplate_offset_y() + pcb_bracket_backplate_thickness() + pcb_bracket_pcb_spacing(),
    pcb_bracket_location().z + pcb_bracket_backplate_h() - pcb_top_offset];

PCB_Bracket();

pillar_l = -pcb_bracket_location().y - pcb_bracket_backplate_offset_y() + top_mount_screw_y_offset();
pillar_z = HE_cartridge_top_offset() + top_mount_screw_z_offset();

module PCB_Bracket() {
    color(parts_color()) {
        difference() {
            union() {
                _base();

                _carriage_mounting_pillars();
                _pcb_mounting_pads();
                _blower_fan_mount_pads();
            }

            _mounting_screw_holes();
            _pcb_heat_insert_slots();
            _arc_for_wires();
            _blower_fan_heat_insert_slots();
            _drag_chain_holder_mount_screws();
            _top_cover_mount_screws();

            _right_blower_intake();
        }
    }
}

module _base() {
    difference() {
        linear_extrude(height = pcb_bracket_backplate_h())
            difference() {
                union() {
                    for (i = [-1, 1])
                        translate([i * pcb_bracket_side_wall_dist() / 2, -extruder_mount_loop_w() / 2]) {
                            uncentered_rounded_square(
                                [
                                    i * pcb_bracket_side_wall_thickness(),
                                    extruder_mount_loop_w() / 2 + pcb_bracket_backplate_offset_y() + pcb_bracket_backplate_thickness()
                                ],
                                rounding=pcb_bracket_rounding());
                        }

                    translate([0, pcb_bracket_backplate_offset_y()])
                        centered_rounded_square(
                            [width, pcb_bracket_backplate_thickness()],
                            rounding=pcb_bracket_rounding(),
                            centerY=false);
                }

                for (i = [-1, 1])
                    translate([i * extruder_mount_screw_dist() / 2, 0])
                        circle(d = m3_screw_d());
            }

        translate([0, 0, pcb_bracket_bottom_mount_thickness()])
            centered_box(
                [width + 2 * eps, extruder_mount_vertical_cut_offset() * 2, pcb_bracket_backplate_h()],
                centerZ=false);

        translate([0, extruder_mount_vertical_cut_offset(), pcb_bracket_backplate_h()])
            rotate([0, 90, 0])
                angle_rounding(1.5, width + 2 * eps, center=true);
    }
}

module _mounting_screw_holes() {
    pcb_bracket_for_each_mounting_screw_pos()
        rotate([90, 0, 0])
            m3_screw(pillar_l + 2 * eps, head_above = false);
}

module _pcb_heat_insert_slots() {
    pcb_bracket_for_each_pcb_mounting_point()
        translate([0, eps, 0])
            rotate([0, 0, 90])
                m3_insert_vertical_hole(pcb_bracket_pcb_spacing());
}

module _pcb_mounting_pads() {
    pcb_bracket_for_each_pcb_mounting_point()
        rotate([-90, 0, 0])
            m3_insert_volcano_pad(pcb_bracket_pcb_spacing());
}

module _arc_for_wires() {
    translate([0, pcb_bracket_backplate_offset_y() + pcb_bracket_backplate_thickness() + eps, 0])
        rotate([90, 0, 0])
            linear_extrude(height = pcb_bracket_backplate_thickness() + 2 * eps)
                circular_cut(20, 20, $fn=40);
}

module _blower_fan_heat_insert_slots() {
    pcb_bracket_for_each_blower_fan_mounting_point()
        m4_insert_vertical_hole(blower_fan_offset_x());
}

module _blower_fan_mount_pads() {
    pcb_bracket_for_each_blower_fan_mounting_point()
        m4_insert_vertical_pad(blower_fan_offset_x());
}

module _carriage_mounting_pillars() {
    for (i = [-1, 1])
        translate([i * top_mount_screw_dist() / 2, pcb_bracket_backplate_offset_y(), pillar_z])
            rotate([-90, 0, 0])
                centered_rounded_box(
                        [back_mount_pillar_side, back_mount_pillar_side, pillar_l],
                        1,
                        centerZ=false,
                        $fn=30);
}

module _drag_chain_holder_mount_screws() {
    pcb_bracket_for_each_drag_chain_screw_pos()
        rotate([90, 0, 0])
            m3_screw(pcb_bracket_backplate_thickness() + 2 * eps, head_above = false);
}

module _top_cover_mount_screws() {
    pcb_bracket_for_each_top_cover_mount_screw_pos()
        rotate([0, 90, 0])
            m3_screw(pcb_bracket_side_wall_thickness() + 2 * eps, head_above = false);
}

module _right_blower_intake() {
    translate([width / 2, 0, -blower_fan_offset_z() + blower_axis_z_offset()])
        rotate([-90, 90, 0])
            linear_extrude(height = 2 * (pcb_bracket_backplate_offset_y() + pcb_bracket_backplate_thickness() + eps), center = true)
                circular_cut(right_blower_intake_w(), right_blower_intake_depth());
}

module pcb_bracket_for_each_mounting_screw_pos() {
    for (i = [-1, 1])
        translate([i * top_mount_screw_dist() / 2, pcb_bracket_backplate_offset_y() - eps, pillar_z])
            children();
}

module pcb_bracket_for_each_drag_chain_screw_pos() {
    for (i = [-1, 1])
        translate([
            i * drag_chain_holder_screw_dist() / 2,
            pcb_bracket_backplate_offset_y() - eps,
            pcb_bracket_backplate_h() - drag_chain_holder_thickness() / 2
        ])
            children();
}

module pcb_bracket_for_each_pcb_mounting_point() {
    translate([
        0,
        pcb_bracket_backplate_offset_y() + pcb_bracket_backplate_thickness(),
        pcb_bracket_backplate_h() - pcb_top_offset
    ])
        for(xz = th_pcb_screw_offsets())
            translate([-xz[0], 0, xz[1]])
                children();
}

module pcb_bracket_for_each_top_cover_mount_screw_pos() {
    for (i = [0, 1])
        mirror([i, 0, 0])
            translate([
                width / 2 + eps,
                pcb_bracket_backplate_offset_y() - pcb_bracket_cover_mount_screw_offset_y(),
                pcb_bracket_backplate_h() - pcb_bracket_cover_mount_screw_offset_z()
            ])
                children();
}

module pcb_bracket_for_each_blower_fan_mounting_point() {
    fan_yz = blower_screw_holes(RB5015)[0];
    fan_mount_yz = [
        abs(pcb_bracket_location().y) - abs(left_blower_location().y) - fan_yz[0], 
        fan_yz[1] - blower_fan_offset_z()];

    translate([0, fan_mount_yz[0], fan_mount_yz[1]])
        for (i = [0, 1])
            mirror([i, 0, 0])
                translate([width / 2, 0, 0])
                    children();
}
