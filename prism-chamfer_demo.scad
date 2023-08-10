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

// Zero-based index of first edge in the polygon to be chamfered.
Start_edge=3;
// Zero-based index of last edge. Must be equal to or greater than Start_edge.
End_edge=5;
// If true, chamfer the edges at the top of the prism. Else, chamfer the bottom edges.
Top=true;
// Length of the sides of the chamfer, or just the top/bottom side if Enable_side2 is true.
Side_length=10;
// If true, allow the length of the sides of the chamfer to be set independantly.
Enable_side2=false;
// If Enable_side2 is true, length of the side parallel to the z-axis. Ignored otherwise.
Side2_length=15;
// Depth of the chamfer in any inner corners between start_edge and end_edge.
Corner_slope="medium"; // [shallow, medium, deep]

difference() {
  polygon_points = [[0,0],[100,0],[100,30],[30,30],[30,70],[100,70],[100,100],[0,100]];
  h=50;
  linear_extrude(height=h)
    polygon(polygon_points, convexity=2);

  prism_chamfer_mask(polygon_points, Start_edge, End_edge, Top?h:0,
                     Side_length, Enable_side2 ? Side2_length : Side_length, Corner_slope);
}
