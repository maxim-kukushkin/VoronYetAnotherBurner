// LDO_Toolhead_PCB.scad -- contains a simplified model and sizes of the toolhead PCB distributed by LDO motors as part of Voron Toolkit */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/pin_headers.scad>
include <NopSCADlib/vitamins/pin_header.scad>

use <../lib/2d_shapes.scad>

$fs = 1;
$fa = 0.4;

eps = 0.004;

function th_pcb_l() = 45;
function th_pcb_left_wing_w() = 30.7;
function th_pcb_right_wing_w() = 36.2;

function th_pcb_screw_offsets() = [
    [th_pcb_l() / 2 - 19, -9],
    [-th_pcb_l() / 2 + 8, -23.5]
];

screw_hole_d = 3.1;

round_cut_r = 10;
pcb_rounding = 1;

right_wing_l = 15.1;

pcb_thickness = 1.6;


LDO_Toolhead_PCB();

module LDO_Toolhead_PCB() {
    _pcb();

    translate([0, 0, pcb_thickness]) {
        // Part Cooling Fan (PCF)
        translate([-18, -6])
            jst_xh_header(jst_xh_header, 2, colour="#333333", pin_colour="silver");

        // Hotend Thermistor (TH0) 
        translate([-10.5, -6])
            jst_xh_header(jst_xh_header, 2, colour="#333333", pin_colour="silver");

        // X Endstop (XES)
        translate([-3.5, -4.7])
            rotate([0, 0, -90])
                jst_xh_header(jst_xh_header, 2, colour="#333333", pin_colour="silver");

        // Hotend Fan (HEF)
        translate([-18, -14.3])
            jst_xh_header(jst_xh_header, 2, colour="#333333", pin_colour="silver");

        // Probe
        translate([2.2, -16.3])
            jst_xh_header(jst_xh_header, 3, colour="#333333", pin_colour="silver");

        // Hotend Heater (HE0)
        translate([-7.5, -15])
            rotate([0, 0, -90])
                green_terminal(gt_3p5, 2, colour="#333333");

        // Motor
        translate([15, -32.5])
            jst_xh_header(jst_xh_header, 4, colour="#333333", pin_colour="silver");

        // Cable
        translate([10.5, -12.5])
            rotate([0, 0, -90])
                box_header(2p54header, 7, 2, right_angle = true);
    }
}

module _pcb() {
    color("#333333")
    linear_extrude(height = pcb_thickness)
    difference() {
        union() {
            difference() {
                centered_rounded_square([th_pcb_l(), -th_pcb_left_wing_w()], pcb_rounding, centerY=false);
                translate([0, -th_pcb_left_wing_w()])
                    circle(r = round_cut_r);
            }

            translate([th_pcb_l() / 2, 0])
                uncentered_rounded_square([-right_wing_l, -th_pcb_right_wing_w()], pcb_rounding);
        }

        for (xy = th_pcb_screw_offsets())
            translate(xy)
                circle(d = screw_hole_d);
    }
}
