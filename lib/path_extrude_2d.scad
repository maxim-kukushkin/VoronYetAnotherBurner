// path_extrude_2d.scad -- contains modules and functions needed to create a polygon following a 2D line */
// Copyright (C) 2023  Maxim Kukushkin <maxim.kukushkin@gmail.com>

/*
This file is part of YetAnotherBurner.

YetAnotherBurner is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

YetAnotherBurner is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with YetAnotherBurner. If not, see <https://www.gnu.org/licenses/>. 
*/

module path_extrude_2d(w, points) {
    num = len(points);
    assert(num > 1, "At least 2 points are needed for extrusion");

    normals = path_extrude_2d_normals(points);
    dots = [for (i = [0 : num - 1]) _offsetted_dots(points[i], w / 2, normals[i])];

    polygon([
        for (d = dots) d[0],
        for (i = [num - 1 : -1 : 0]) dots[i][1]
    ]);
}

function path_extrude_2d_normals(points) =
    let(num = len(points))
    let(first_point_angle = _points_angle(points[0], points[1]))
    let(last_point_angle = _points_angle(points[num - 2], points[num - 1]))
    let(middle_angles = (num == 2) ? [] :
        [for (i = [1 : num - 2])
            let(alpha = _points_angle(points[i - 1], points[i])) // vector from prev point
            let(beta = _points_angle(points[i], points[i + 1])) // vector to next point
            let(adjust_normal = (min(alpha, beta) + 180) < max(alpha, beta))
            let(avg = (alpha + beta) / 2)
            let(normal_angle = adjust_normal ? avg + 180 : avg)
                //echo(str("alpha=", alpha, " beta=", beta, " normal_angle=", normal_angle))
                normal_angle])
        [first_point_angle, for (x = middle_angles) x, last_point_angle];

// Return the angle of p0->p1 vector in [0..360] range
function _points_angle(p0, p1) =
    let(diff_x = p1.x - p0.x, diff_y = p1.y - p0.y)
    let(atan_ = diff_x == 0 ? 0 : atan(diff_y / diff_x))
        //echo(str("d_x=",diff_x, " d_y=", diff_y, " atan=", atan_))
        diff_x == 0 ?
            (diff_y >= 0 ? 90 : 270) :
            (diff_y == 0 ? (diff_x >= 0 ? 0 : 180) :
                (diff_y < 0 ? (atan_ < 0 ? 360 + atan_ : 180 + atan_) : (atan_ < 0 ? 180 + atan_ : atan_)));

function _offsetted_dots(p, o, angle) =
    [
        [p.x + o * cos(angle - 90), p.y + o * sin(angle - 90)],
        [p.x + o * cos(angle + 90), p.y + o * sin(angle + 90)]];

/// TESTS
//dots = [[-5, 0], [0, 5], [5, 0]]; // ^
//dots = [[5, 0], [0, 5], [-5, 0]]; // rev. ^
//dots = [[-5, 5], [0, 0], [5, 5]]; // V
//dots = [[5, 5], [0, 0], [-5, 5]]; // rev. V
//dots = [[-5, -5], [0, 0], [-5, 5]]; // >
//dots = [[-5, 5], [0, 0], [-5, -5]]; // rev. >
//dots = [[5, -5], [0, 0], [5, 5]]; // <
//dots = [[5, 5], [0, 0], [5, -5]]; // rev. <

//dots = [[0, 0], [0, 6], [-4, 3]];
//dots = [[-4, 3], [0, 6], [0, 0]];

//dots = [[4, 3], [0, 0], [6, 0]];
dots = [[6, 0], [0, 0], [4, 3]];

path_extrude_2d(2, dots);
