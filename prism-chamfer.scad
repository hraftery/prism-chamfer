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


//===========
// Variables
//===========

ff=0.001; // Fudge factor: amount of extra mask to prevent zero thickness planes.


//===========
// Functions
//===========

function translate_towards(p0, p1, dist) = p0 + (dist/norm(p1-p0))*(p1-p0);
function min_index(v, only_first=false) = search(min(v), v, only_first?1:0);
function max_index(v, only_first=false) = search(max(v), v, only_first?1:0);
function mod(a,n) = (a+n)%n; // add support for (slightly) negative modulo

//Find the cartesian angle of a vector from p0 to p1.
//Note contrary to docs, atan2 returns [-180,180]
function angle_of(p0, p1) = atan2(p1.y-p0.y, p1.x-p0.x);

//Calculate angle halfway between the angles of a vertex.
//Ref: https://math.stackexchange.com/a/4750179/787256
function corner_angle(p0, p1, p2) =
  let (a0       = angle_of(p0,p1),
       a1       = angle_of(p1,p2),
       deltaA   = a1 - a0,
       inner_dA = deltaA < -180 ? deltaA + 360 :
                  deltaA >  180 ? deltaA - 360 :
                                  deltaA)
    a0 + (inner_dA/2);

//Return the three points that define the vertex at the point specified
function vertex_points(polygon_points, point_index) =
  let (num_pts = len(polygon_points))
    [ polygon_points[mod(point_index-1, num_pts)],
      polygon_points[mod(point_index  , num_pts)],
      polygon_points[mod(point_index+1, num_pts)] ];

//Determine orientation of polygon. Ref:
//  https://en.wikipedia.org/wiki/Curve_orientation#Orientation_of_a_simple_polygon
function is_polygon_orientation_clockwise(polygon_points) =
  let (min_x_indices                = min_index([for (pt = polygon_points) pt.x]),
       min_y_index_in_min_x_indices = min_index([for (i = min_x_indices) polygon_points[i].y]),
       min_x_min_y_index            = min_x_indices[min_y_index_in_min_x_indices[0]],
       vertex_pts                   = vertex_points(polygon_points, min_x_min_y_index))
    is_vertex_convex(vertex_pts, true);

function is_vertex_convex(pts, cw) =
  let (A = pts[0], B = pts[1], C = pts[2],
       //This determinate calc is the same as cross(AB,BC). But we have points,
       //so use the simplification from the polygon orientation reference above.
       det = (B.x-A.x)*(C.y-A.y) - (C.x-A.x)*(B.y-A.y),
       right_turn = det < 0)
    cw == right_turn; //right turns are convex when going cw, and vice-versa


//===========
//  Modules  
//===========

//Create masks for 1 or more prism edges and any corners in between.
//See "prism-chamfer_demo.scad" for a description of the arguments.
module prism_chamfer_mask(polygon_pts, start_edge=0, end_edge=0, height=0,
                          side=1, side2=0, corner_slope="medium") {
  num_pts = len(polygon_pts);
  assert(num_pts >= 3);
  assert(end_edge >= start_edge);
  // Allow specifying edges past the first point, in the -ve or +ve direction,
  // up to but not including a complete rotation. Allows the corner at the
  // first point to be included in a contiguous range.
  assert(start_edge > -num_pts && end_edge < 2*num_pts);
  
  points = [ for(i = [start_edge:end_edge+1])
             [polygon_pts[mod(i,num_pts)].x, polygon_pts[mod(i,num_pts)].y, height] ];
  
  cw = is_polygon_orientation_clockwise(polygon_pts);
  
  include_start = is_vertex_convex(vertex_points(polygon_pts, start_edge), cw);
  include_end   = is_vertex_convex(vertex_points(polygon_pts, end_edge+1), cw);
  
  prism_chamfer_mask_raw(points, side, side2, cw,
                         corner_slope  = corner_slope,
                         include_start = include_start,
                         include_end   = include_end);
}

//Create masks for 1 or more prism edges and any corners inbetween,
//but their points and end conditions must be specified.
module prism_chamfer_mask_raw(points, side=1, side2=0, cw=false, top=undef,
                              corner_slope="medium", include_start=false, include_end=false) {
  num_points = len(points);
  assert(num_points>1);
  for(i = [0:num_points-2]) {
    prism_chamfer_mask_e(points[i], points[i+1], side, side2, cw, top,
                         include_p0 = i==0            ? include_start : true,
                         include_p1 = i==num_points-2 ? include_end   : true);
    
    if(i<num_points-2) {
      prism_chamfer_mask_c(points[i], points[i+1], points[i+2], side, side2, cw, top,
                           slope = corner_slope);
    }
  }
}

//Create a chamfer mask for a single prism edge.
module prism_chamfer_mask_e(p0, p1, side=1, side2=0, cw=false, top=undef,
                            include_p0=true, include_p1=true) {
  side2 = side2 == 0 ? side : side2;    //set sides equal unless side2 is specified
  top = is_undef(top) ? p0.z > 0 : top; //set top to positivity of z unless specified
  assert(p0.z == p1.z); //only points in the same x-y plane are supported
  assert(side>0 && side2>0);
  assert(p0!=p1);

  //Conditional transforms don't seem to be supported. Fortunately mirror
  //seems to be a nop if the argument is [0,0,0], so we can use a variable
  //and this dodgy conditional assignment construct instead:
  mr_args = (!top &&  cw) ? [[1,0,0],[ 90,0,-90]] : //bottom, cw
            ( top &&  cw) ? [[0,0,0],[-90,0,-90]] : //top, cw
            ( top && !cw) ? [[1,0,0],[-90,0, 90]] : //top, ccw
                            [[0,0,0],[ 90,0, 90]];  //bottom, ccw
    
  length = norm(p1-p0) + (include_p0?ff:-ff) + (include_p1?ff:-ff);
  p0_fudged = translate_towards(p0, p1, include_p0?-ff:ff); //shift p0 fwd or back by fudge factor
  translate(p0_fudged) rotate([0, 0, angle_of(p0, p1)]) //align with p0 -> p1
    mirror(mr_args[0]) rotate(mr_args[1]) //orient to x-y plane, in +x direction
      linear_extrude(height=length)
        polygon([[-ff,-ff],[side,-ff],[-ff,side2]]);
}

//Create a chamfer mask for the corner between two prism edges.
module prism_chamfer_mask_c(p0, p1, p2, side=1, side2=0, cw=false, top=undef,
                            slope="medium") {
  side2 = side2 == 0 ? side : side2;    //set sides equal unless side2 is specified
  top = is_undef(top) ? p0.z > 0 : top; //set top to positivity of z unless specified
  assert(p0.z == p1.z && p1.z == p2.z); //only points in the same x-y plane are supported
  assert(side>0 && side2>0);
  assert(p0!=p1 && p1!=p2 && p0!=p2);
  
  corner_angle = corner_angle(p0, p1, p2);
  
  if(is_vertex_convex([p0,p1,p2],cw)) {
    //no mask needed for outside corners
  }
  else if(slope=="deep") {    //then carve out as much as possible
    intersection() {
      //Just extend the two edge chamfers so they overlap fully.
      prism_chamfer_mask_e(p1, translate_towards(p1,p0,-side), side, side2, cw, top);
      prism_chamfer_mask_e(translate_towards(p1,p2,-side), p1, side, side2, cw, top);
    }
  }
  else if(slope=="shallow") { //then carve out as little as possible. Inspired by corner-tools.scad
    translate(p1) rotate([0, 0, corner_angle])
      rotate([0, 0, 45]) //rotate to put it symmetrical around the x axis
        polyhedron(points = [[-ff,-ff,ff], [side,-ff,ff], [-ff,side,ff], [-ff,-ff,-side2]],
                   faces  = [[0,2,1], [0,1,3], [0,3,2], [1,2,3]],
                   convexity = 100);
  }
  else {                      //otherwise, do a "medium" half-way corner
    c0 = [p1.x - side*cos(corner_angle), p1.y - side*sin(corner_angle), p1.z];
    c1 = [p1.x + side*cos(corner_angle), p1.y + side*sin(corner_angle), p1.z];
    intersection() {
      //Same as "deep", but also intersect a third mask with angle half-way between
      //the first two. c0 and c1 just extend the edge either side of the corner point.
      prism_chamfer_mask_e(p1, translate_towards(p1,p0,-side), side, side2, cw, top);
      prism_chamfer_mask_e(translate_towards(p1,p2,-side), p1, side, side2, cw, top);
      prism_chamfer_mask_e(c0, c1, side, side2, cw, top);
    }
  }
}
