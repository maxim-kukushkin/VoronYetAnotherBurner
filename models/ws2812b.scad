// ws2812b.scad -- contains a simplified model and sizes of ws2812b RGB LED */
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

use <../lib/3d_shapes.scad>

function ws2812b_pcb_d() = 9.6;
function ws2812b_pcb_h() = 1.2;
function ws2812b_pcb_flat_w() = 0.8;
function ws2812b_led_side() = 5;
function ws2812b_led_h() = 1.55;
function ws2812b_components_h() = 0.5;
function ws2812b_contact_offset_l() = 1.4;
function ws2812b_contact_offset_w() = 1.7;
function ws2812b_contact_l() = 2.7;
function ws2812b_contact_w() = 1.4;

contact_w_dist = (ws2812b_pcb_d() - 2 * ws2812b_contact_offset_w() - 3 * ws2812b_contact_w()) / 2;
contact_l_dist = ws2812b_pcb_d() - 2 * ws2812b_contact_offset_l() - 2 * ws2812b_contact_l();

ws2812b();

module ws2812b(from_base = true) {
    z_offset = from_base ? 0 : -(ws2812b_pcb_h() + ws2812b_led_h());
    translate([0, 0, z_offset]) {
        // pcb
        color("#333333")
            cylinder(d = ws2812b_pcb_d(), h = ws2812b_pcb_h());

        // led
        color("#DDDDDD")
            translate([0, 0, ws2812b_pcb_h() - eps])
                centered_box([ws2812b_led_side(), ws2812b_led_side(), ws2812b_led_h() + eps], centerZ=false);

        // contacts with tin
        color("silver")
            for(i = [-1, 1])
                for(j = [-1, 0, 1])
                    translate([
                        i * (contact_l_dist / 2 + ws2812b_contact_l() / 2),
                        j * (contact_w_dist + ws2812b_contact_w()),
                        eps
                    ])
                        centered_box([ws2812b_contact_l(), ws2812b_contact_w(), -1 - eps], centerZ = false);
    }
}
