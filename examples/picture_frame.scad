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


include <../prism-chamfer.scad>;

difference() {
  polygon_points = [[0,0],[0,10],[7,10],[7,0],[3.5,0],[3.5,1],[6,1],[6,9],[1,9],[1,1],[3.5,1],[3.5,0]];
  h=1;
  linear_extrude(height=h)
    polygon(polygon_points, convexity=4);

  //Outer
  prism_chamfer_mask(polygon_points, -1, 3, h,
                     0.3, 0.1);
  //Inner
  prism_chamfer_mask(polygon_points, 5, 9, h,
                     0.1, 0, "deep");
}
