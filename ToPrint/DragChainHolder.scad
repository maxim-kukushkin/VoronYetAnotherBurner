// DragChainHolder.scad -- contains the model of the Drag Chain Holder part of YetAnotherBurner */
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

use <../lib/heat_inserts.scad>
use <../lib/screws.scad>
use <../lib/bezier.scad>

length = drag_chain_location().y + drag_chain_w() / 2 - drag_chain_holder_location().y;
top_straight_l = 15;
bottom_straight_l = drag_chain_w() + 0.5;

top_thickness = drag_chain_holder_thickness();
bottom_thickness = 4 + 1 + 2; // heat insert + gap + bottom

top_level_diff = drag_chain_holder_location().z + top_thickness / 2 - drag_chain_location().z;
bottom_level_diff = drag_chain_holder_location().z - (drag_chain_location().z - bottom_thickness);

top_width = HE_cartridge_w() - 2 * pcb_bracket_rounding();
bottom_width = drag_chain_screw_dist() + m3_heat_insert_d() + 2 * heat_insert_min_offset();

bezier_dot_num = 30;
top_y1 = top_thickness / 2;
top_y2 = -top_thickness / 2;

bottom_y1 = top_y1 - top_level_diff;
bottom_y2 = top_y2 - bottom_level_diff;

DragChainHolder();

module DragChainHolder() {
    color(parts_color())
    rotate([90, 0, 90])
        difference() {
            _main_body();

            // mounting screw holes
            for (i = [-1, 1])
                translate([0, 0, i * drag_chain_holder_screw_dist() / 2])
                    rotate([0, 0, 180])
                        m3_insert_vertical_hole(0);

            // bottom heat insert slots
            for (i = [-1, 1])
                translate([
                    length - drag_chain_w() / 2,
                    top_thickness / 2 - top_level_diff,
                    i * drag_chain_screw_dist() / 2])
                    rotate([0, 0, 90])
                        m3_insert_vertical_hole(0);
        }
}

module _main_body() {
    horizontal_dots = [
        [0, top_y1],
        [top_straight_l, top_y1],
        for (x = BezierDots(
            [top_straight_l, top_y1],
            [top_straight_l + 7, top_y1],
            [length - bottom_straight_l - 3, bottom_y1],
            [length - bottom_straight_l, bottom_y1],
            bezier_dot_num)) x,
        [length, bottom_y1],
        [length, bottom_y2],
        // Bottom bezier
        for (x = BezierDots(
            [length - bottom_straight_l, bottom_y2],
            [length - bottom_straight_l - 5, bottom_y2],
            [top_straight_l + 3, top_y2],
            [top_straight_l, top_y2],
            bezier_dot_num)) x,
        [0, top_y2]
    ];

    top_bez_offset = 20;
    bottom_bez_offset = 15;
    vertical_dots = [
        for (x = BezierDots(
            [0, top_width / 2],
            [top_bez_offset, top_width / 2],
            [length - bottom_bez_offset, bottom_width / 2],
            [length, bottom_width / 2],
            bezier_dot_num)) x,
        for (x = BezierDots(
            [length, -bottom_width / 2],
            [length - bottom_bez_offset, -bottom_width / 2],
            [top_bez_offset, -top_width / 2],
            [0, -top_width / 2],
            bezier_dot_num)) x
    ];
    
    intersection() {
        linear_extrude(height = top_width, center = true)
            polygon(horizontal_dots);

        rotate([90, 0, 0])
            linear_extrude(height = (bottom_level_diff + top_thickness) * 2, center = true)
                polygon(vertical_dots);
    }
}
