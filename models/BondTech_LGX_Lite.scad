// BondTech_LGX_Lite.scad -- contains a simplified model and sizes of BondTech LGX Lite extruder */
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

use <../lib/bezier.scad>

motor_screws_frame_angle = 60;
function motor_body_d() = 36.5;
motor_body_h = 19;

body_h = 38;
body_w = 23.7;
body_l = 38;
gear_housing_top_offset = 0.8;

function mounting_screw_to_hole_w_offset1() = 2.5;
function mounting_screw_to_hole_w_offset2() = 12;
function mounting_screw_to_hole_l_offset() = 9.5;
function mounting_screw_to_hole_h_offset1() = 9.5;
function mounting_screw_to_hole_h_offset2() = 28.5;
function filament_shaft_w_offset() = 17;
function filament_shaft_l_offset() = 19;
function filament_shaft_to_front_offset() = body_w - filament_shaft_w_offset();
function full_extruder_width() = body_w + motor_body_h;
function extruder_body_width() = body_w;
function extruder_body_length() = body_l;
function extruder_body_height() = body_h;

function tension_lever_thickness() = 1.25;
function tension_lever_w() = 4.8;
function tension_lever_w_offset() = 8.1;

function motor_offset_z() = body_h - gear_housing_top_offset - motor_body_d() / 2;

BondtechLGXLite();

module BondtechLGXLite() {
    translate([-filament_shaft_l_offset(), filament_shaft_w_offset(), 0])
        rotate([90, 0, 0])
            mainBody();
    
    translate([0, filament_shaft_w_offset(), motor_offset_z()])
        rotate([-90, -45, 0])
            pancakeStepper();
}

//!pancakeStepper();
module pancakeStepper() {
    chute_offset = 5.3;
    chute_w = 7.8;
    chute_depth = 0.8;
    side_chute_d = 3.2;
    side_chute_angle = 70;
    screw_offset = 21.5;
    screw_rounding = 3;
    screw_pad_h = 2.9;
    
    color("#333333") {
        difference() {
            cylinder(d = motor_body_d(), h = motor_body_h);
            
            translate([0, 0, chute_offset]) {
                linear_extrude(height = chute_w) {
                    difference() {
                        circle(d = motor_body_d() * 1.5);
                        circle(d = motor_body_d() - 2 * chute_depth);
                    }

                    rotate(side_chute_angle)
                        for(i = [-1, 1])
                            translate([i * (motor_body_d() / 2 - chute_depth), 0])
                                circle(d = side_chute_d);
                }
            }
        }
        
        poly_offset = screw_offset * tan(motor_screws_frame_angle / 2) - screw_rounding;
        linear_extrude(height = screw_pad_h)
            minkowski() {
                polygon([
                    [-screw_offset, 0],
                    [0, poly_offset],
                    [screw_offset, 0],
                    [0, -poly_offset]
                ]);
                
                circle(r = screw_rounding);
            }
    }
}

//!mainBody();
module mainBody() {
    small_rounding = 3.2;
    big_rounding = 7.4;
    dot_number = 20;
    
    gear_housing_r = motor_body_d() / 2;
    gear_housing_left_offset = 1;
    gear_housing_w = 21.5;
    
    driver_gear_h_offset = 16;
    driver_gear_w_offset = 10;
    driver_gear_right_cut_l = 13;
    driver_gear_right_cut_depth = 3.1;
    driver_gear_center_offset = 9.4;
    
    driver_gear_width = 5.2;
    driver_wheel_width = 3.8;
    driver_gear_d = 17.8;
    
    bottom_tube_cut_d = 4;
    bottom_tube_cut_depth = 3;
    top_insert_cut_d = 5;
    top_insert_cut_depth = 8.2;
    
    filament_shaft_d = 1.8;
    
    mounting_screw_hole_depth = 13;
    mounting_screw_hole_d = 3.1;
    
    reductor_gear_d = 23;
    reductor_gear_center_h_offset = 30;
    reductor_gear_center_l_offset = 11;
    reductor_gear_w_offset = 2.2;
    reductor_gear_w = 3.2;
    
    center_offset_h = 20;
    tension_lever_step_degrees = 15;
    tension_lever_l = 23.7;
    tension_lever_w_offset = 8.3;
    
    logo_depth = 0.5;
    
    color("#666666")
    difference() {
        union() {
            // main body
            dots = [
                for(i = [0 : dot_number])
                    PointAlongBez4(
                        [small_rounding, small_rounding],
                        [small_rounding + 5, small_rounding + 20],
                        [body_l - small_rounding - 20, body_h - small_rounding - 5],
                        [body_l - small_rounding, body_h - small_rounding],
                        i / dot_number),
                [body_l - small_rounding, big_rounding],
                [body_l - big_rounding, small_rounding]
            ];

            linear_extrude(height = body_w) {
                minkowski() {
                    polygon(dots);
                    circle(r = small_rounding);
                }
                
                translate([body_l - big_rounding, big_rounding])
                    circle(r = big_rounding);
            }
            
            // gear housing
            housing_center_x = gear_housing_left_offset + gear_housing_r;
            linear_extrude(height = gear_housing_w)
                translate([housing_center_x, body_h - gear_housing_top_offset - gear_housing_r]) {
                    circle(r = gear_housing_r);
                    square([body_l - housing_center_x - small_rounding, gear_housing_r]);
                }
        }
        
        // right gear cut
        gear_cut_r = driver_gear_right_cut_depth / 2 + pow(driver_gear_right_cut_l, 2) / (8 * driver_gear_right_cut_depth);
        gear_cut_l_offset = gear_cut_r - driver_gear_right_cut_depth;
        translate([body_l + gear_cut_l_offset, driver_gear_h_offset, driver_gear_w_offset])
            cylinder(h = body_w, r = gear_cut_r);
        
        translate([filament_shaft_l_offset(), -eps, filament_shaft_w_offset()]) {
            rotate([-90, 0, 0]) {
                // filament shaft
                cylinder(d = filament_shaft_d, h = body_h * 2, $fn=20);
                
                // PTFE tube cut
                cylinder(d = bottom_tube_cut_d, h = bottom_tube_cut_depth);
            }
        }
        
        // top PTFE tube shaft
        translate([filament_shaft_l_offset(), body_h - gear_housing_top_offset + eps, filament_shaft_w_offset()])
            rotate([90, 0, 0])
                cylinder(d = top_insert_cut_d, h = top_insert_cut_depth + eps);
        
        // screw holes
        // bottom
        for (i = [-1, 1])
            for (z = [mounting_screw_to_hole_w_offset1(), mounting_screw_to_hole_w_offset2()])
                translate([filament_shaft_l_offset() + i * mounting_screw_to_hole_l_offset(), -eps, filament_shaft_w_offset() - z])
                    rotate([-90, 0, 0])
                        cylinder(d = mounting_screw_hole_d, h = mounting_screw_hole_depth + eps);
        // top
        translate([filament_shaft_l_offset() + mounting_screw_to_hole_l_offset(), body_h - gear_housing_top_offset + eps, filament_shaft_w_offset() - mounting_screw_to_hole_w_offset2()])
            rotate([90, 0, 0])
                cylinder(d = mounting_screw_hole_d, h = mounting_screw_hole_depth + eps);
        // side
        for (y = [mounting_screw_to_hole_h_offset1(), mounting_screw_to_hole_h_offset2()])
            translate([body_l + eps, y, filament_shaft_w_offset() - mounting_screw_to_hole_w_offset2()])
                rotate([0, -90, 0])
                    cylinder(d = mounting_screw_hole_d, h = mounting_screw_hole_depth + eps);
    }
    
    // driver gears
    for (i = [-1, 1])
        translate([filament_shaft_l_offset() + i * driver_gear_center_offset, driver_gear_h_offset, driver_gear_w_offset]) {
            color("#333333")
            cylinder(d = driver_gear_d, h = driver_gear_width);

            color("Silver")
            translate([0, 0, driver_gear_width])
                cylinder(d = driver_gear_d, h = driver_wheel_width);
        }
    
    // reductor gear
    color("#333333")
    translate([reductor_gear_center_l_offset, reductor_gear_center_h_offset, reductor_gear_w_offset])
        cylinder(d = reductor_gear_d, h = reductor_gear_w);
        
    // tension lever
    color("Silver")
    translate([filament_shaft_l_offset(), center_offset_h, filament_shaft_w_offset() - tension_lever_w_offset()])
        for (angle = [-tension_lever_step_degrees, 0, tension_lever_step_degrees])
            rotate([0, 0, angle])
                hull() {
                    cylinder(d = tension_lever_w(), h = tension_lever_thickness(), center = true);
                    translate([0, tension_lever_l - tension_lever_w() / 2, 0])
                        cylinder(d = tension_lever_w(), h = tension_lever_thickness(), center = true);
                }
}
