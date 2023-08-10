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
  polygon_points = [[0,0],[5,10],[25,10],[30,0],[28,1],[26,1],[24,0],[22,1],[20,1],[18,0],[16,1],[14,1],[12,0],[10,1],[8,1],[6,0],[4,1],[2,1]];
  h=1;
  linear_extrude(height=h)
    polygon(polygon_points, convexity=4);

  prism_chamfer_mask(polygon_points, 3, 17, h,
                     1.0, 0.5, "deep");
  prism_chamfer_mask(polygon_points, 3, 17, 0,
                     1.0, 0.5, "deep");
}
