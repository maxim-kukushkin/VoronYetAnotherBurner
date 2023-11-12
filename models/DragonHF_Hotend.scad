// DragonHF_Hotend.scad -- contains a simplified model and sizes of Dragon HighFlow Hotend */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

$detailed = false;

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

include <MCAD/materials.scad>
use <MCAD/boxes.scad>

use <../lib/3d_shapes.scad>

outer_heatsink_h = 26;

heater_dist = 2.5;
heater_height = 11.5;
heater_screws_d = 1.3;
heater_screw_offset = 6;
heater_screw_hole_cap_depth = 4;

inner_heatsink_offset = 2.3;
inner_heatsink_ending_d = 2.8;
inner_heatsink_ending_l = 1.5;

pillar_d = 2.3;
pillar_dist = 12;
pillar_offset = pillar_dist / 2;

nozzle_offset = 0.7;
nozzle_h = 5;

function hotend_heatsink_d() = 22;
function hotend_heatsink_h() = outer_heatsink_h;
function hotend_screw_offset() = 8;
function hotend_total_h() = outer_heatsink_h + heater_dist + heater_height + nozzle_offset + nozzle_h;
function hotend_ptfe_slot_depth() = 1;

DragonHF_Hotend($detailed = true);

module DragonHF_Hotend() {
    rotate([180, 0, 0])  {
        outerHeatsink();
        translate([0, 0, outer_heatsink_h + heater_dist])
            heater_block();
        translate([0, 0, outer_heatsink_h])
            heater_to_heatsink_attachment();
        translate([0, 0, inner_heatsink_offset])
            inner_heatsink();
        translate([0, 0, outer_heatsink_h + heater_dist])
            rotate([180, 0, 0])
                heat_isolator();
        translate([0, 0, outer_heatsink_h + heater_dist + heater_height + nozzle_offset])
            nozzle();
    }
}

//!outerHeatsink($fn=40, $detailed=true);
module outerHeatsink() {
    outer_r = hotend_heatsink_d() / 2;
    top_skew = 0.5;
    
    side_cut_w = 8.9;
    side_cut_rounding = 3;
    side_cut_top_offset = 3.5;
    side_cut_bottom_offset = 2.5;
    side_cut_h_chamfer = 2.5;
    side_cut_v_chamfer = 1;
    
    bottom_ext_d = 22.3;
    bottom_ext_h = 1.5;
    bottom_ext_chamfer = 0.25;
    
    blade_w = 1;
    blade_dist = 0.9;
    blade_cut_n = 10;
    blade_cut_depth = 1.5;
    first_blade_cut_offset = 3.5;
    
    holding_screw_l = 6;
    holding_screw_d = 2;
    holding_screw_chamfer = 0.7;
    
    v6_screw_offset = 6;
    v6_screw_d = 2;
    v6_screw_chamfer = 0.5;
    
    filament_hole_inner_d = 1.8;
    ptfe_slot_d = 4;
    
    heatbreak_hole_d = 10;
    
    pillar_hole_depth = 2.3;
    pillar_hole_skew_x = 0.5;
    pillar_hole_skew_y = 0.9;
    
    color("#333333")
    difference() {
        union() {
            // main body
            cylinder(d = hotend_heatsink_d(), h = outer_heatsink_h);
            
            if ($detailed) {
                translate([0, 0, outer_heatsink_h - bottom_ext_h])
                    cylinder(d = bottom_ext_d, h = bottom_ext_h);
            }
        }
        
        // small chamfers at the top and bottom
        if ($detailed) {
            cylinder_chamfer_cut(outer_r, top_skew);
            translate([0, 0, outer_heatsink_h])
                rotate([0, 180, 0])
                    cylinder_chamfer_cut(bottom_ext_d / 2, bottom_ext_chamfer);
        }
        
        // main inner space
        scale_factor = side_cut_v_chamfer / side_cut_h_chamfer;
        cut_shape_w = side_cut_rounding * scale_factor;
        cut_x = side_cut_w / 2 - 0.8;
        cut_skew_start = outer_r - 5.5;
        
        for (i = [0 : 3])
            rotate([0, 0, i * 90]) {
                translate([0, 0, side_cut_top_offset]) {
                    rotate([90, 0, 0])
                        uncentered_rounded_box(
                            [
                                side_cut_w,
                                outer_heatsink_h - side_cut_top_offset - side_cut_bottom_offset,
                                outer_r + 2 * eps
                            ],
                            rounding=side_cut_rounding,
                            centerX=true);
                }
                
                rotate([90, 0, 0])
                hull() {
                    translate([0, side_cut_top_offset + cut_shape_w, cut_skew_start])
                        scale([1, 0.2, 1])
                            rotate_extrude()
                                polygon([
                                    [0, 0],
                                    [0, outer_r],
                                    [cut_x + outer_r, outer_r],
                                    [cut_x, 0]]);

                    translate([0, outer_heatsink_h - side_cut_bottom_offset - cut_shape_w, cut_skew_start])
                        scale([1, 0.2, 1])
                            rotate_extrude()
                                polygon([
                                    [0, 0],
                                    [0, outer_r],
                                    [cut_x + outer_r, outer_r],
                                    [cut_x, 0]]);
                }
            }
                        
        // heatsink blades
        for (i = [0 : blade_cut_n - 1])
            translate([0, 0, first_blade_cut_offset + i * (blade_dist + blade_w)])
                ring(outer_r + eps, outer_r - blade_cut_depth, h = blade_dist);
        
        // holding screw holes
        for (i = [0 : 3])
            rotate([0, 0, 45 + i * 90])
                translate([hotend_screw_offset(), 0, -eps]) {
                    cylinder(d = holding_screw_d, h = holding_screw_l, $fn=20);
                    if ($detailed)
                        hole_chamfer_cut(holding_screw_d / 2, holding_screw_chamfer);
                }
                
        // v6 screw holes
        for (s = [-1, 1])
            translate([s * v6_screw_offset, 0, -eps]) {
                cylinder(d = v6_screw_d, h = outer_heatsink_h / 2, $fn=20);
                if ($detailed)
                    hole_chamfer_cut(v6_screw_d / 2, v6_screw_chamfer);
            }
            

        // Filament shaft and PTFE tube slot for the filament
        translate([0, 0, -eps]) {
            cylinder(d = ptfe_slot_d, h = hotend_ptfe_slot_depth());
            cylinder(d = filament_hole_inner_d, h = outer_heatsink_h / 2, $fn=20);
        }
        
        // top slot for the inner heatsink
        translate([0, 0, side_cut_top_offset - inner_heatsink_ending_l])
            cylinder(d = inner_heatsink_ending_d + 0.2, h = inner_heatsink_ending_l + eps);
        
        // bottom hole for the heatbreak
        translate([0, 0, outer_heatsink_h / 2])
            cylinder(d = heatbreak_hole_d, h = outer_heatsink_h / 2 + eps);
        
        // pillar holes
        if ($detailed)
            for (i = [-1, 1], j = [-1, 1])
                translate([i * pillar_offset, j * pillar_offset, outer_heatsink_h + eps])
                    rotate([180, 0, 0]) {
                        cylinder(d = pillar_d, h = pillar_hole_depth + eps);
                        hole_chamfer_cut(pillar_d / 2, pillar_hole_skew_x, pillar_hole_skew_y);
                    }
                
        // heater holding screw holes
        if ($detailed)
            for (i = [-1, 1])
                translate([i * heater_screw_offset, 0, outer_heatsink_h + eps])
                    rotate([180, 0, 0])
                        cylinder(d = heater_screws_d, h = side_cut_bottom_offset + 2 * eps);
    }
}

//!heater_block($fn=40, $detailed=true);
module heater_block() {
    heater_length = 23;
    heater_width = 16;
    heater_screw_hole_d = 2.7;
    heater_screw_hole_bottom_chamfer = 0.2;
    heater_screw_hole_top_chamfer = 0.4;
    
    heater_sensor_hole_d = 3;
    heater_sensor_hole_offset = 6;
    heater_sensor_hole_z_offset = 6;
    heater_sensor_screw_hole_d = 2.5;
    heater_sensor_screw_chamfer = 0.3;

    heater_cartridge_hole_d = 6;
    heater_cartridge_hole_offset = 6;
    heater_cartridge_hole_z_offset = 7.5;
    heater_cartridge_hole_cut_w = 1.4;
    heater_cartridge_screw_offset = 12.5;
    heater_cartridge_screw_hole_d = 2.5;
    heater_cartridge_screw_chamfer = 0.3;
    
    heater_to_shaft_offset = 8;
    nozzle_shaft_d = 5;
    nozzle_shaft_bottom_chamfer = 0.7;
    nozzle_shaft_top_chamfer = 0.5;
    
    pillar_hole_depth = 4;
    pillar_hole_skew_x = 0.5;
    pillar_hole_skew_y = 0.9;
    
    color("Silver")
    difference() {
        // main body
        translate([0, -heater_to_shaft_offset]) {
            uncentered_box([heater_width, heater_length, heater_height], centerX=true);
        }
        
        // shaft
        translate([0, 0, -eps])
            cylinder(d = nozzle_shaft_d, h = heater_height + 2 * eps);
        if ($detailed) {
            hole_chamfer_cut(nozzle_shaft_d / 2, nozzle_shaft_top_chamfer);
            translate([0, 0, heater_height])
                hole_chamfer_cut(nozzle_shaft_d / 2, nozzle_shaft_bottom_chamfer, facing_down=true);
        }
        
        // sensor hole
        translate([0, -heater_sensor_hole_offset, heater_sensor_hole_z_offset])
            rotate([0, 90, 0])
                cylinder(d = heater_sensor_hole_d, h = heater_width + 2 * eps, center=true);
        
        // sensor screw hole
        translate([0, -heater_sensor_hole_offset, heater_height + eps])
            rotate([180, 0, 0])
                cylinder(d = heater_sensor_screw_hole_d, h = heater_height / 2);
        if ($detailed)
            translate([0, -heater_sensor_hole_offset, heater_height])
                hole_chamfer_cut(heater_sensor_screw_hole_d / 2, heater_sensor_screw_chamfer, facing_down=true);
        
        // holding screws
        for (i = [-1, 1])
            translate([i * heater_screw_offset, 0, -eps]) {
                cylinder(d = heater_screws_d, h = heater_height + 2 * eps);
                translate([0, 0, eps + heater_height - heater_screw_hole_cap_depth])
                    cylinder(d = heater_screw_hole_d, h = heater_height);
                if ($detailed) {
                    translate([0, 0, eps + heater_height])
                        hole_chamfer_cut(heater_screw_hole_d / 2, heater_screw_hole_bottom_chamfer, facing_down=true);
                    hole_chamfer_cut(heater_screws_d / 2, heater_screw_hole_top_chamfer);
                }
            }
            
        // cartridge screw
        translate([0, heater_cartridge_screw_offset, -eps])
            cylinder(d = heater_cartridge_screw_hole_d, h = heater_height + 2 * eps);
        if ($detailed) {
            translate([0, heater_cartridge_screw_offset])
                hole_chamfer_cut(heater_cartridge_screw_hole_d / 2, heater_cartridge_screw_chamfer);
            translate([0, heater_cartridge_screw_offset, heater_height])
                hole_chamfer_cut(heater_cartridge_screw_hole_d / 2, heater_cartridge_screw_chamfer, facing_down=true);
        }
            
        // cartridge hole and cut
        translate([0, heater_cartridge_hole_offset, heater_cartridge_hole_z_offset]) {
            rotate([0, 90, 0])
                cylinder(d = heater_cartridge_hole_d, h = heater_width + 2 * eps, center=true);
            
            centered_box([heater_width + 2 * eps, heater_length, heater_cartridge_hole_cut_w], centerY=false);
        }
        
        // pillar holes
        if ($detailed)
            for (i = [-1, 1], j = [-1, 1])
                translate([i * pillar_offset, j * pillar_offset, -eps]) {
                    cylinder(d = pillar_d, h = pillar_hole_depth + eps);
                    cone(pillar_d / 2 + pillar_hole_skew_x, pillar_d / 2, pillar_hole_skew_y);
                }
    }
    
    color("#333333")
    translate([0, heater_cartridge_screw_offset, heater_height])
        screw(M3_dome_screw, 8);
    
    color("#333333")
    translate([0, -heater_sensor_hole_offset, heater_height - 0.5])
        screw(M3_grub_screw, 4);
}

module heater_to_heatsink_attachment() {
    for (i = [-1, 1], j = [-1, 1])
        translate([i * pillar_offset, j * pillar_offset, -eps])
            color("Silver")
            cylinder(d = pillar_d, h = heater_dist + 2 * eps);
    
    for (i = [-1, 1])
        translate([i * heater_screw_offset, 0, -eps])
            color("#333333")
            cylinder(d = heater_screws_d, h = heater_dist + heater_height - heater_screw_hole_cap_depth);
}

//!inner_heatsink($fn=40);
module inner_heatsink() {
    heatsinkColor = "SandyBrown";
    heatbreakColor = "Silver";
    filament_hole_d = 1.8;
    first_ring_offset = 3.7;
    first_ring_d = 8;
    ring_dist = 1;
    ring_h = 0.5;
    ring_d = 9;
    ring_n = 7;
    main_shaft_l = 14.5;
    main_shaft_d = 3.8;
    heatbreak_d = 2.7;
    heatbreak_l = 1;
    base_d = 7.8;
    base_l = 7.2;
    base_skew = 1;
    nut_h = 1.8;
    thread_d = 6;
    thread_l = 4.6;
    
    isolator_inner_d_top = 8;
    isolator_outer_d_top = 9.6;
    isolator_inner_d_bottom = 8.6;
    isolator_outer_d_bottom = 10.5;
    isolator_top_l = 7.2;
    isolator_bottom_l = 2;

    z1 = inner_heatsink_ending_l;
    z2 = z1 + main_shaft_l;
    z3 = z2 + heatbreak_l;
    z4 = z3 + base_l;
    z5 = z4 + nut_h;

    color(heatsinkColor)
    difference() {
        union() {
            cylinder(h = inner_heatsink_ending_l, d = inner_heatsink_ending_d);

            translate([0, 0, z1 - eps])
                cylinder(h = main_shaft_l, d = main_shaft_d + eps);
                
            for (i = [0 : ring_n - 1])
                translate([0, 0, first_ring_offset + i * (ring_h + ring_dist)])
                    cylinder(d = i==0 ? first_ring_d : ring_d, h = ring_h);
           
            translate([0, 0, z3 - eps])
                difference() {
                    cylinder(d = base_d, h = base_l + eps);            
                    cylinder_chamfer_cut(base_d / 2, base_skew);
                }
                      translate([0, 0, z4 - eps])
                mX_nut(nut_h + eps, base_d / 2);
            translate([0, 0, z5 - eps])
                cylinder(d = thread_d, h = thread_l);
        }
        
        translate([0, 0, -eps])
            cylinder(d = filament_hole_d, h = z5 + thread_l + 2 * eps);
    }

    color(heatbreakColor)
    translate([0, 0, z2 - eps])
        difference() {
            cylinder(d = heatbreak_d, h = heatbreak_l + eps);
            
            translate([0, 0, -eps])
                cylinder(d = filament_hole_d, h = heatbreak_l + 3 * eps);
        }
}

//!heat_isolator();
module heat_isolator() {
    inner_d_top = 8;
    outer_d_top = 9.6;
    inner_d_bottom = 8.6;
    outer_d_bottom = 10.5;
    top_l = 7.2;
    bottom_l = 2;
    
    color("white")
    linear_extrude(height = bottom_l)
        difference() {
            circle(d = outer_d_bottom);
            circle(d = inner_d_bottom);
        }
        
    color("white")
    translate([0, 0, bottom_l - eps])
        linear_extrude(height = top_l + eps)
            difference() {
                circle(d = outer_d_top);
                circle(d = inner_d_top);
            }
}

//!nozzle();
module nozzle() {
    thread_d = 6;
    thread_l = 7.5;
    nut_h = 2.1;
    nut_d = 7.8;
    
    nozzle_flat_r = 0.4;
    
    filament_d = 1.8;
    nozzle_d = 0.4;
    
    color(Steel) {
        difference() {
            union() {
                translate([0, 0, -thread_l])
                    cylinder(d = thread_d, h = thread_l + eps);
                mX_nut(nozzle_h, nut_d / 2);
            }        
            
            cut_x = nut_d;
            cut_y = cut_x * (nozzle_h - nut_h) / (nut_d / 2 - nozzle_flat_r);
            rotate_extrude()
                polygon([
                    [0, nozzle_h],
                    [nozzle_flat_r, nozzle_h],
                    [nozzle_flat_r + cut_x, nozzle_h - cut_y],
                    [nozzle_flat_r + cut_x, nozzle_h + 1],
                    [0, nozzle_h + 1]
                ]);
            
            rotate([180, 0, 0])
                cylinder(d = filament_d, h = thread_l + eps);
            translate([0, 0, -eps])
                cylinder(d = nozzle_d, h = nozzle_h + 2 * eps);
        }
    }
}

// Auxiliary functions
module cylinder_chamfer_cut(r, x, y = -1, eps=eps) {
    y1 = y == -1 ? x : y;
    rotate_extrude()
        polygon([[r - x, -eps], [r, y1], [2 * r, y1], [2 * r, -eps]]);
}

module hole_chamfer_cut(r, x, y = -1, facing_down=false, eps=eps) {
    y1 = y == -1 ? x : y;
    rotate([facing_down ? 180 : 0, 0, 0])
        translate([0, 0, -eps])
            cone(r + x, r, y1);
}

module ring(outerR, innerR, h) {
    linear_extrude(height = h)
        difference() {
            circle(outerR);
            circle(innerR);
        }
}

module cone(bottomR, topR, h) {
    if (h != 0 && (topR != 0 || bottomR != 0)) {
        if (topR == 0) {
            rotate_extrude()
                polygon([[0, 0], [0, h], [bottomR, 0]]);
        } else if (bottomR == 0) {
            rotate_extrude()
                polygon([[0, 0], [0, h], [topR, h]]);
        } else {
            linear_extrude(height = h, scale = topR / bottomR)
                circle(bottomR);
        }
    }
}

module mX_nut(h, r) {
    linear_extrude(height = h + eps)
        rotate([0, 0, 30])
            polygon([for(i = [0:5]) [r * cos(60 * i), r * sin(60 * i)]]);
}
