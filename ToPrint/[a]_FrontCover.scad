// [a]_FrontCover.scad -- contains the model of the Front Cover part of YetAnotherBurner */
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
use <DragonHF/HE_cartridge_front.scad>

use <../lib/2d_shapes.scad>
use <../lib/3d_shapes.scad>
use <../lib/misc.scad>
use <../lib/screws.scad>
use <../models/BondTech_LGX_Lite.scad>
use <../models/ws2812b.scad>

wall = 2;
front_wall = cover_front_plate_thickness();
width = HE_cartridge_w();
side_rounding = cover_top_plate_thickness();
front_inner_rounding = 13;

cartridge_front_y = -HE_cartridge_front_depth() + cover_split_offset();

total_depth = abs(cartridge_front_y) + cooling_fan_depth() + front_wall;
function front_panel_depth() = total_depth;

top_lid_length = total_depth - (front_wall + front_inner_rounding);

front_plate_h = pcb_bracket_backplate_h() - front_inner_rounding + HE_cartridge_h() + HE_cartridge_bottom_screw_offset() + 0.3;

motor_offset = front_cover_location().z - extruder_location().z - motor_offset_z();
fan_offset = front_cover_location().z - HE_cartridge_front_location().z + HE_cartridge_fan_offset_z();

led_housing_outer_r = total_depth - abs(cartridge_front_y);
led_housing_inner_r = led_housing_outer_r - 2;

FrontCover();

module FrontCover() {
    color(cover_color()) {
        difference() {
            union() {
                _top_lid();
                _front_rounding();
                _side_walls();
                _front_panel();
                _top_screw_shafts();

                _motor_led_holders();
                _bottom_led_housing();
                _bottom_led_holders();
                _wire_guides();
            }

            _bottom_mounting_screws();
            _top_screw_cuts();
            _led_wire_hole();
            _right_blower_intake();
        }
    }
}

module _top_lid() {
    rotate([90, 0, 0])
        linear_extrude(height = top_lid_length + front_wall - cover_top_plate_thickness())
            cover_rounded_profile(width, side_rounding);
}

//!_front_rounding();
module _front_rounding() {
    inner_dots = circv(front_inner_rounding, from=0, to=90);
    outer_dots = reverse(circv(front_inner_rounding + cover_top_plate_thickness(), from=0, to=90));
    dots = [
        for (x = inner_dots) x,
        [0, front_inner_rounding + cover_top_plate_thickness()],
        for (x = outer_dots) [x.x + front_wall - cover_top_plate_thickness(), x.y]
    ];
    translate([0, -top_lid_length, -front_inner_rounding])
        rotate([90, 0, -90])
            linear_extrude(height = width - 2 * wall + 2 * eps, center = true)
                polygon(dots);
}

//!_side_walls();
module _side_walls() {
    disc_r = front_inner_rounding + side_rounding;
    disc_offset = top_lid_length + front_wall - side_rounding;
    for (i = [0, 1])
        mirror([i, 0, 0])
            translate([width / 2 - wall, 0, 0])
                rotate([90, 0, 90]) {
                    translate([-disc_offset, side_rounding - disc_r, 0])
                        intersection() {
                            union() {
                                disc_offset = wall - side_rounding;
                                translate([0, 0, disc_offset])
                                    disc(outer_r = disc_r, h = side_rounding * 2);
                                if (disc_offset > 0)
                                    cylinder(r = disc_r, h = disc_offset + eps);
                            }
                            uncentered_box([-disc_r, disc_r, wall + eps]);
                        }

                    translate([0, eps, 0])
                        uncentered_box([-disc_offset, -(pcb_bracket_backplate_h() - front_part_h_diff()), wall]);

                    translate([cartridge_front_y, -disc_r + side_rounding + eps, 0]) {
                        uncentered_box([
                            -(total_depth - abs(cartridge_front_y) - side_rounding),
                            -front_plate_h - eps,
                            wall
                        ]);

                        translate([-eps, 0, 0])
                            uncentered_box([
                                abs(cartridge_front_y) + eps,
                                -(pcb_bracket_backplate_h() - front_part_h_diff() - disc_r + side_rounding),
                                wall
                            ]);
                    }
                }
}

//!_front_panel();
module _front_panel() {
    translate([0, -total_depth + front_wall, -front_inner_rounding])
        difference() {
            translate([0, 0, eps])
                rotate([180, 0, 0])
                    linear_extrude(height = front_plate_h + eps) {
                        centered_square([width, front_wall - side_rounding + eps], centerY=false);
                        translate([0, front_wall - side_rounding, 0])
                            cover_rounded_profile(width, side_rounding);
                    }

            echo (front_wall);
            // motor window
            translate([0, eps, -(motor_offset - front_inner_rounding)])
                rotate([90, 0, 0])
                    cylinder(d = motor_body_d() + 2 * cover_motor_insert_w() + 0.2, h = front_wall + 2 * eps);

            // fan window
            translate([0, eps, -(fan_offset - front_inner_rounding)])
                rotate([90, 0, 0])
                    cylinder(d = cooling_fan_d(), h = front_wall + 2 * eps);
        }
}

module _bottom_mounting_screws() {
    front_cover_for_each_bottom_screw_pos()
        rotate([-90, 0, 0]) {
            cylinder(d = m3_screw_d(), h = front_wall + 2 * eps);
            cylinder(d = m3_screw_cap_d(), h = eps + m3_cap_h());
        }
}

module _top_screw_shafts() {
    shaft_offset = cover_front_mount_screw_offset();

    for (i = [1, -1])
        translate([
            i * cover_join_screw_dist() / 2,
            0,
            cover_top_plate_thickness() - shaft_offset])
            difference() {
                length = top_lid_length + front_inner_rounding + eps;
                rotate([90, 0, 0])
                    centered_rounded_box(
                        [shaft_offset, 2 * shaft_offset, length],
                        rounding=1,
                        centerZ=false,
                        $fn=20);

                translate([0, -length, shaft_offset])
                    rotate([0, 90, 0])
                        angle_rounding(front_inner_rounding, shaft_offset + 2 * eps, center=true); 
            }
}

module _top_screw_cuts() {
    front_cover_for_each_top_screw_pos() {
        rotate([-90, 0, 0])
            cylinder(d = m3_screw_d(), h = total_depth);
        translate([0, eps, 0])
            rotate([90, 0, 0])
                cylinder(d = m3_screw_cap_d(), h = total_depth);
    }
/*
    for (i = [1, -1])
        translate([
            i * cover_join_screw_dist() / 2,
            -total_depth,
            cover_top_plate_thickness() -cover_front_mount_screw_offset()])
            rotate([-90, 0, 0]) {
                cylinder(d = m3_screw_cap_d(), h = 9);
            }
*/
}


module _motor_led_holders() {
    translate([0, -total_depth + front_wall - eps, -motor_offset])
        rotate([-90, 0, 0])
            for (i = [0 : 3])
                rotate([0, 0, 45 + i * 90])
                    translate([-motor_body_d() / 2 - cover_motor_insert_inner_w() - 1, 0, 0])
                        _led_holder();
}

module _led_holder(extra_h = 0) {
    wall = 1.2;
    inner_l = ws2812b_pcb_h() + ws2812b_components_h() + 0.1;
    inner_w = ws2812b_pcb_d() + 0.2;
    outer_l = 2 * wall + inner_l;
    difference() {
        linear_extrude(height = ws2812b_pcb_d() + extra_h)
            difference() { 
                centered_square([-outer_l, 2 * wall + inner_w], centerX = false);
                translate([-outer_l + wall, 0])
                    centered_square([inner_l, inner_w], centerX = false);
                translate([-outer_l - eps, 0])
                    centered_square(
                        [wall + 2 * eps, ws2812b_pcb_d() - 2 * ws2812b_contact_offset_l() + 0.3],
                        centerX = false);
            }

        translate([-wall - eps, 0, extra_h + ws2812b_pcb_d() / 2 - ws2812b_led_side() / 2]) {
            uncentered_box([wall + 2 * eps, ws2812b_led_side() + 0.2, ws2812b_pcb_d()], centerY=true);

            rotate([0, 90, 0])
                cylinder(d =  ws2812b_led_side() * 0.7, h = wall + 2 * eps, $fn=20);
        }
    }
}

//!_bottom_led_housing();
module _bottom_led_housing() {
    housing_l = 10;
    end_scale = 0.6;
    for (i = [0, 1])
        mirror([i, 0, 0])
            translate([
                -width / 2 + wall,
                cartridge_front_y,
                -front_inner_rounding - front_plate_h + eps]) {
                rotate([0, -90, 0])
                    intersection() {
                        union() {
                            disc_offset = wall - side_rounding;
                            translate([0, 0, disc_offset])
                                disc(outer_r = led_housing_outer_r, h = side_rounding * 2);
                            if (disc_offset > 0)
                                cylinder(r = led_housing_outer_r, h = disc_offset + eps);
                        }
                        uncentered_box(
                            [-led_housing_outer_r, 2 * led_housing_outer_r, wall],
                            centerY=true);
                    }

                dots = concat(
                    circv(r = led_housing_outer_r, from=270, to=360),
                    reverse(circv(r = led_housing_inner_r, from=270, to=360)));
                translate([-eps, 0, 0])
                    rotate([0, 90, 0])
                        linear_extrude(height = housing_l + 2 * eps)
                            polygon(dots);

                translate([housing_l, 0, 0])
                    scale([end_scale, 1, 1])
                        rotate([0, 0, -90])
                            rotate_extrude(angle = 90)
                                polygon(dots);
            }

    translate([0, -total_depth + front_wall - eps, -front_inner_rounding - front_plate_h])
        linear_extrude(height = 1)
            difference() {
                w = total_depth - abs(cartridge_front_y) - front_wall + eps;
                l = width - 2 * wall - 2 * housing_l;
                centered_square([l, w], centerY=false);
                for (i = [-1, 1])
                    translate([i * l / 2, w])
                        scale([end_scale, 1])
                            circle(r = led_housing_inner_r);
            }
}

module _bottom_led_holders() {
    x_offset = 7;
    x_position = -width / 2 + wall + x_offset;
    for (i = [0, 1])
        mirror([i, 0, 0])
            translate([x_position, cartridge_front_y, -front_inner_rounding - front_plate_h])
                rotate([-40, 0, 0])
                    translate([0, 0, -led_housing_inner_r - eps])
                        rotate([0, 0, 70])
                    _led_holder(2);
}

module _wire_guides() {
    guide_w = 1.2;
    guide_l = 30;
    guide_h = cooling_fan_depth() - 0.3;
    guide_offset = cooling_fan_side() / 2 + 0.3 + guide_w / 2;
    translate([0, -total_depth + front_wall - eps, -fan_offset])
        rotate([-90, 0, 0])
            for (i = [[0, 1.0], [90, 0.7], [180, 1.0]])
                rotate([0, 0, i[0]])
                    translate([guide_offset, 0, 0])
                        centered_box([guide_w, guide_l * i[1], guide_h], centerZ = false);
}

module _led_wire_hole() {
    translate([width / 2, 0, -cover_led_wire_hole_offset()])
        centered_box([wall * 2, -cover_led_wire_hole_side(), cover_led_wire_hole_side()], centerY=false);
}

module _right_blower_intake() {
    axis_z = -pcb_bracket_backplate_h() - blower_fan_offset_z() + blower_axis_z_offset();
    d = right_blower_intake_w() + 2;
    translate([
        width / 2 + eps,
        right_blower_location().y - front_cover_location().y - blower_axis_y_offset(),
        axis_z])
        rotate([0, -90, 0])
            cylinder(d = d, h = wall + 2 * eps);

    translate([width / 2 + eps, eps, axis_z])
        uncentered_box([-wall - 2 * eps, -abs(cartridge_front_y), -d]);
}

module front_cover_for_each_bottom_screw_pos() {
    translate([0, -total_depth - eps, -fan_offset])
        for (i= [-1, 1])
            translate([i * cooling_fan_screw_dist() / 2, 0, -cooling_fan_screw_dist() / 2])
                children();
}

module front_cover_for_each_top_screw_pos() {
    for (i = [1, -1])
        translate([
            i * cover_join_screw_dist() / 2,
            -total_depth + 9,
            cover_top_plate_thickness() -cover_front_mount_screw_offset()
        ])
            children();
}
