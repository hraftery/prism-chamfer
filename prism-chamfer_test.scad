//==============================================================================
//
//           prism-chamfer - the missing chamfer tool for OpenSCAD
//
// Author:  Heath Raftery
// Origin:  http://github.com/hraftery/prism-chamfer
// License: GPLv3, see LICENSE for terms.
//
// See the accompanying README for instructions on use.
//
//==============================================================================


include <prism-chamfer.scad>;


echo("*************");
echo("Tests Started");

assert(translate_towards([ 0, 0], [ 1, 0], 0.5) == [ 0.5, 0]);
assert(translate_towards([-1, 0], [ 1, 0], 0.5) == [-0.5, 0]);
assert(translate_towards([-2, 1], [ 1, 1], 3.5) == [ 1.5, 1]);
assert(translate_towards([ 0, 0], [ 1, 1], sqrt(2)) == [ 1, 1]);
assert(translate_towards([ 0, 0], [ 4, 3], 10) == [ 8, 6]);
assert(translate_towards([10,10], [14, 7], 10) == [18, 4]);
assert(translate_towards([-5, 5], [-1, 2], 10) == [ 3,-1]);
assert(translate_towards([ 3, 5], [-1, 2], 10) == [-5,-1]);

assert(mod( 5,10) == 5);
assert(mod(10,10) == 0);
assert(mod(11,10) == 1);
assert(mod(20,10) == 0);
assert(mod( 0,10) == 0);
assert(mod(-1,10) == 9);
assert(mod(-9,10) == 1);

assert(angle_of([ 0, 0],[ 1, 0]) == 0);
assert(angle_of([-1, 0],[ 1, 0]) == 0);
assert(angle_of([-1, 1],[ 0, 1]) == 0);
assert(angle_of([-2,-1],[-1,-1]) == 0);
assert(angle_of([ 1, 0],[ 0, 0]) == 180);
assert(angle_of([ 1, 0],[-1, 0]) == 180);
assert(angle_of([ 0, 1],[-1, 1]) == 180);
assert(angle_of([-1,-1],[-2,-1]) == 180);
assert(angle_of([ 0, 0],[ 0, 1]) == 90);
assert(angle_of([ 0,-1],[ 0, 1]) == 90);
assert(angle_of([ 1,-1],[ 1, 0]) == 90);
assert(angle_of([-1,-2],[-1,-1]) == 90);
assert(angle_of([ 0, 1],[ 0, 0]) == -90);
assert(angle_of([ 0, 1],[ 0,-1]) == -90);
assert(angle_of([ 1, 0],[ 1,-1]) == -90);
assert(angle_of([-1,-1],[-1,-2]) == -90);

assert(corner_angle([ 0, 1],[0,0],[ 2, 0]) == -45);
assert(corner_angle([ 1, 1],[0,0],[ 2,-2]) == -90);
assert(corner_angle([ 1, 0],[0,0],[ 0,-2]) == -135+360);
assert(corner_angle([ 1,-1],[0,0],[-2,-2]) == 180);
assert(corner_angle([ 0,-1],[0,0],[-2, 0]) == 135);
assert(corner_angle([-1,-1],[0,0],[-2, 2]) == 90);
assert(corner_angle([-1, 0],[0,0],[ 0, 2]) == 45);
assert(corner_angle([-1, 1],[0,0],[ 2, 2]) == 0);

assert(vertex_points([[0,0],[1,1],[2,2],[3,3]], 1) == [[0,0],[1,1],[2,2]]);
assert(vertex_points([[0,0],[1,1],[2,2],[3,3]], 2) == [[1,1],[2,2],[3,3]]);
assert(vertex_points([[0,0],[1,1],[2,2],[3,3]], 3) == [[2,2],[3,3],[0,0]]);
assert(vertex_points([[0,0],[1,1],[2,2],[3,3]], 0) == [[3,3],[0,0],[1,1]]);

poly=[[0,0],[100,0],[100,30],[30,30],[30,70],[100,70],[100,100],[0,100]];
ylop=[[0,100],[100,100],[100,70],[30,70],[30,30],[100,30],[100,0],[0,0]];
assert(is_polygon_orientation_clockwise(poly) == false);
assert(is_polygon_orientation_clockwise(ylop) == true);

assert(is_vertex_convex(vertex_points(poly, 0), false) == true);
assert(is_vertex_convex(vertex_points(poly, 1), false) == true);
assert(is_vertex_convex(vertex_points(poly, 2), false) == true);
assert(is_vertex_convex(vertex_points(poly, 3), false) == false);
assert(is_vertex_convex(vertex_points(poly, 4), false) == false);
assert(is_vertex_convex(vertex_points(poly, 5), false) == true);
assert(is_vertex_convex(vertex_points(poly, 6), false) == true);
assert(is_vertex_convex(vertex_points(poly, 7), false) == true);
assert(is_vertex_convex(vertex_points(ylop, 0), true)  == true);
assert(is_vertex_convex(vertex_points(ylop, 1), true)  == true);
assert(is_vertex_convex(vertex_points(ylop, 2), true)  == true);
assert(is_vertex_convex(vertex_points(ylop, 3), true)  == false);
assert(is_vertex_convex(vertex_points(ylop, 4), true)  == false);
assert(is_vertex_convex(vertex_points(ylop, 5), true)  == true);
assert(is_vertex_convex(vertex_points(ylop, 6), true)  == true);
assert(is_vertex_convex(vertex_points(ylop, 7), true)  == true);

echo("Tests Finished");
echo("**************");
