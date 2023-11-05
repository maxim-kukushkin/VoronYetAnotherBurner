// 2d_shapes.scad -- contains auxiliary functions needed to work with 2D objects */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

use <bezier.scad>

eps = 0.004;

function circv(r = 1, fn = 32, from = 0, to = 360) =
    let(loop_limit = (to - from == 360) ? fn - 1 : fn)
    [ for(i = [0 : loop_limit])
        let(angle = from + (to - from) * i / fn)
            [r * cos(angle), r * sin(angle)] ];

function squarev(coords, rotation = 0) =
    let(
        dist = sqrt(pow(coords.x / 2, 2) + pow(coords.y / 2, 2)),
        angle = asin(coords.y / 2 / dist))
    [
        [dist * cos(angle + rotation), dist * sin(angle + rotation)],
        [dist * cos(180 - angle + rotation), dist * sin(180 - angle + rotation)],
        [dist * cos(180 + angle + rotation), dist * sin(180 + angle + rotation)],
        [dist * cos(-angle + rotation), dist * sin(-angle + rotation)],
    ];

// supports negative sizes
module uncentered_rounded_square(coords, rounding, centerX = false, centerY = false) {
    absX = abs(coords[0]);
    absY = abs(coords[1]); 
    assert(absX > 2 * rounding, "X size doesn't exceed the rounding");
    assert(absY > 2 * rounding, "Y size doesn't exceed the rounding");
    translate([
        centerX ? 0 : (coords.x > 0 ? absX/2 : -absX/2),
        centerY ? 0 : (coords.y > 0 ? absY/2 : -absY/2)
    ]) {        
        square([absX - 2 * rounding, absY], center=true);
        square([absX, absY - 2 * rounding], center=true);
        for (i = [-1, 1], j = [-1, 1])
            translate([i * (absX / 2 - rounding), j * (absY / 2 - rounding)])
                circle(r = rounding);
    }       
}               
                
// supports negative sizes
module centered_rounded_square(coords, rounding, centerX = true, centerY = true) {
    uncentered_rounded_square(coords, rounding, centerX, centerY);
}

// supports negative sizes
module centered_square(coords, centerX = true, centerY = true) {
    translate([
        centerX ? (-abs(coords.x) / 2) : (coords.x > 0 ? 0 : coords.x),
        centerY ? (-abs(coords.y) / 2) : (coords.y > 0 ? 0 : coords.y)
    ])
        square([abs(coords.x), abs(coords.y)]);
}

// supports negative sizes
module uncentered_square(coords, centerX = false, centerY = false) {
    centered_square(coords, centerX, centerY);
}

module smooth_right_angle_2d(x_width, y_width, dot_number = 20, eps = eps) {
    dots = [
        [-eps, -eps],
        for(i = [0 : dot_number])
            PointAlongBez4(
                [x_width , -eps],
                [x_width / 2, -eps],
                [-eps, y_width / 2],
                [-eps, y_width ],
                i / dot_number)
    ];

    polygon(dots);
}

module angle_rounding_2d(r, angle = 90, eps = eps, fromX = true) {
    if (angle == 90)
        difference() {
            translate([-eps, -eps])
                square([r + eps, r + eps]);
            translate([r, r])
                circle(r + eps);
        }
    else {
        dots = [
            [-eps, -eps],
            [r, -eps],
            [-eps + (r + eps) * cos(angle), -eps + (r + eps) * sin(angle)]
        ];
        rotate([0, 0, fromX ? 0 : -angle + 90])
        difference() {
            polygon(dots);
            rotate([0, 0, angle / 2])
                translate([(r + eps) / cos(angle / 2), 0, 0])
                    circle((r + eps) * tan(angle / 2), $fn=100);
        }
    }
}

// this module provides a cutting shape to make a circular cut given the length and
// depth of the cut
module circular_cut(l, depth, eps = eps) {
    if (depth < l / 2) {
        b = l / 2; // 'b' is half of the chord
        // alpha is the angle between radius and the chord going between the top point and one of
        // the points of the original chord
        alpha = atan(b / depth);
        // beta ios the angle between radiuses going to the above chord
        beta = 180 - 2 * alpha;
        c = b / tan(beta); // 'c' is the distance between the original chord and the center of the circle

        intersection() {
            translate([0, -eps])
                centered_square([l, depth + eps], centerY = false);
            translate([0, -c])
                circle(r = c + depth);
        }
    } else {
        translate([0, -eps])
            centered_square([l , depth - l / 2 + eps], centerY = false);
        translate([0, depth - l / 2])
            intersection() {
                circle(d = l);
                translate([0, -eps])
                    centered_square([l, l / 2 + eps], centerY = false);
            }
    }
}


