// FullModel.scad -- contains a view of the entire view of YetAnotherBurner assembled together */
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

use <models/BondTech_LGX_Lite.scad>
use <models/DragonHF_Hotend.scad>
use <models/LDO_Toolhead_PCB.scad>

use <lib/screws.scad>
use <lib/2d_shapes.scad>
use <lib/3d_shapes.scad>

use <common.scad>
use <ToPrint/DragonHF/HE_cartridge_back.scad>
use <ToPrint/DragonHF/HE_cartridge_front.scad>
use <ToPrint/ExtruderMount.scad>
use <ToPrint/PCB_Bracket.scad>
use <ToPrint/DragChainHolder.scad>
use <ToPrint/CoolingDuct_x2.scad>
use <ToPrint/[a]_TopCover.scad>
use <ToPrint/[a]_FrontCover.scad>
use <ToPrint/ExtruderLeverExtension.scad>
use <ToPrint/[c]_MotorWindowInsert.scad>

$fs = 1;
$fa = 0.4;

eps = 0.004;

/******
DEVICES
******/
rotate([-90, 0, -90])
    translate([/*Y*/ -164.2, /*Z*/ -131.6, /*X*/-21.6])
        import("3rd_party/x_frame_V2TR_MGN12_left.stl");
        
rotate([90, 0, -90])
    translate([/*Y*/ -164.2, /*Z*/ -168.4, /*X*/-21.6])
        import("3rd_party/x_frame_V2TR_MGN12_right.stl");
        
rotate([0, 0, -90])
    translate([/*Y*/ -175.6, /*X*/ -141.7, -56.5])
        import("3rd_party/KlickyProbe_AB_mount_v2.stl");

translate(extruder_location())
    rotate([0, 0, 180])
        BondtechLGXLite();
    
translate(HE_location())
    rotate([0, 0, 0])
        DragonHF_Hotend($detailed=false);
        
translate(left_blower_location())
    rotate([90, 0, -90])
        blower(RB5015);

translate(right_blower_location())
    rotate([90, 0, -90])
        blower(RB5015);

/*
translate([
    right_blower_location().x - blower_depth(RB5015),
    right_blower_location().y - blower_axis(RB5015).x,
    right_blower_location().z + blower_axis(RB5015).y
    ])
        rotate([90, -45, 90])
            translate([-blower_axis(RB5015).x, -blower_axis(RB5015).y])
                blower(RB5015);
        */

translate(HE_fan_location())
    rotate([-90, 0, 0])
        fan(fan40x11);

translate(th_pcb_location())
    rotate([90, 0, 180])
        LDO_Toolhead_PCB();

translate(drag_chain_location())
    drag_chain();

translate(accelerometer_location())
    accelerometer();

translate(extruder_location())
    translate([0, 0, extruder_body_height() - 1])
        PTFE_tube();
        
/*******
Toolhead parts
*******/

translate(HE_cartridge_location()) 
    HE_cartridge_back();

translate(HE_cartridge_front_location())
    translate([0, -0.1, 0])
    HE_cartridge_front();
        
translate(extruder_mount_location())
    ExtruderMount();

translate(pcb_bracket_location())
    PCB_Bracket();

translate(drag_chain_holder_location())
    DragChainHolder();

translate(cooling_duct_location())
    CoolingDuct();
mirror([1, 0, 0])
    translate(cooling_duct_location())
        CoolingDuct();

translate(top_cover_location())
    TopCover();

translate(front_cover_location())
    translate([0, -0.1, 0])
    FrontCover();

translate(extruder_location())
    translate([0, -tension_lever_w_offset(), extruder_body_height() + 1])
        rotate([90, 0, 180])
            ExtruderLeverExtension();

translate(motor_window_insert_location())
    MotorWindowInsert();

/*******
Screws
*******/

color("#333333")
for (i = [-1, 1])
    translate([i * top_holding_screw_dist() / 2, -HE_catridge_hook_thickness(), 0])
        rotate([90, 0, 0])
            m3_screw(6, for_hole_cutting = false);

color("#333333")
for (i = [-1, 1])
    translate([
        extruder_mount_location().x + i * extruder_mount_screw_dist() / 2,
        extruder_mount_location().y - extruder_mount_screw_y_offset(),
        extruder_location().z])
        m3_screw(extruder_mount_h() + 5, for_hole_cutting = false, with_washer=true);

color("#333333")
for (i = [-1, 1])
    translate([
            i * bottom_mount_screw_dist() / 2,
            -46,
            -bottom_mount_screw_z_offset()
        ])
        rotate([90, 0, 0])
            m3_screw(50, for_hole_cutting = false);

color("#333333")
for (i = [-1, 1])
    translate([
            i * top_mount_screw_dist() / 2,
            0,
            top_mount_screw_z_offset()
        ])
        rotate([90, 0, 0])
            m3_screw(20, for_hole_cutting = false);

/*******
AUX
*******/

module drag_chain() {
    chain_h = 14.5;
    chain_l = 150;
    chain_end_l = 17.5;
    chain_end_thickness = 2;
    chain_wall_thickness = 1.8;

    chain_offset_z = 43.3;
    chain_offset_y = 38;

    right_x = drag_chain_screw_dist() / 2 + drag_chain_screw_offset();
    left_x = right_x - chain_end_l;
    
    color("#333333") {
        linear_extrude(height = chain_end_thickness) 
            difference() {
                translate([right_x, 0])
                    uncentered_square([-chain_end_l, drag_chain_w()], centerY=true);

                for (i = [-1, 1])
                    translate([i * drag_chain_screw_dist() / 2, 0])
                        circle(d = m3_screw_d());
            }

        for (i = [-1, 1])
            translate([left_x, i * (drag_chain_w() / 2 - chain_wall_thickness / 2), 0])
                rotate([90, 0, 0])
                    linear_extrude(height = chain_wall_thickness, center = true)
                        polygon([
                            [0, chain_end_thickness - eps],
                            [0, chain_h],
                            [chain_end_l, chain_end_thickness - eps]
                ]);

        translate([left_x + eps, 0, 0])
            uncentered_box([-chain_l + chain_end_l, drag_chain_w(), chain_h], centerY=true);
    }
}

module accelerometer() {
    color("#444444")
    rotate([0, 90, 0])
    linear_extrude(height = accelerometer_h())
        difference() {
            translate([0, accelerometer_screw_side_offset()])
                centered_square([accelerometer_l(), -accelerometer_w()], centerY=false);

            for (i = [-1, 1])
                translate([i * accelerometer_screw_dist() / 2, 0])
                    circle(d = 2.35);
        }
}

module PTFE_tube() {
    color("white")
    linear_extrude(height = 30)
        difference() {
            circle(d = 4);
            circle(d = 1.9);
        }
}
