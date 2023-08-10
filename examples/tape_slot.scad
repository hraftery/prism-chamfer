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
  polygon_points = [[0,0],[0,2.607],[1.507,2.607],[0.8,1.9],[0.8,1.6],[1.4,1.6],[1.4,0.4],[5.9,0.4],[5.9,1.6],[9.0,1.6],[9.0,1.9],[8.5,2.4],[9.8,2.4],[9.8,0]];
  h=100;
  linear_extrude(height=h)
    polygon(polygon_points, convexity=2);

  prism_chamfer_mask(polygon_points, 2, 10, h,
                     0.3, 0.8, "medium");
}
