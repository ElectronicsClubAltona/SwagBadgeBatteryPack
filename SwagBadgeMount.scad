/*
 * --- Pins are too large for holes, and do not fit
 * --- Plate obscures charge lamp --- can it be made smaller?
 *
 * Approx 2 hour print time with Cura's 'super quality' profile for Ender 3 v2.
 */
/*
 * Licence:
 * Copyright 2021 Peter Chubb
 * Licensed under CC-By-SA-NC 4.0
 * https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
 */

/* Adjust for your battery size */
battery_width = 25;
battery_length = 45;
battery_height = 9;
/* Space for wires to come out */
wirewidth = 8;
right = 0;

/* These are the centres for the 2.5⌀ mounting holes */
d1 = 72;
d2 = 31;
armwidth = 5;
/* the mounting holes are for M2.5 screws.
 * Use slightly more than that, both for clearance, and 
 * because rendering for printing usually undersizes holes.
 */
screw = 2.65;
/*
 * How much space to allow above the battery.
 * Fill it with foam rubber after making, if it's too big.
 */
clearance = 0.5;
// Material thickness
mat = 1;
// Allowance for spaces so that things mate firmly but not too tightly.
slack = 0.2;
length = battery_length + clearance;
wid = battery_width + clearance;
use <pins.scad>;

/*
* Generic washer/spacer
*/
module washer(height=1, inside_diam = 2.55, outside_diam = 3.5) {
    translate([0, 0, height/2]) difference() {
    cylinder(h=height, r=outside_diam/2, center=true);
    cylinder(h=height+4, r=inside_diam/2, center= true);
}}
$fn=60;

/*
 * One arm of the frame.
 * Basically a round-ended rectangle.
 */
module arm(length, width) {
  union(){
   // Decided I don't want a stiffening rib
   // translate([0.1*length, 0, 1])
   //   cube([(length-width)*0.8, 0.2, 2], center=true);
        
     hull() {
       translate([(width - length)/2, 0, 0])
         cylinder(h=mat, r=width/2, center=true);        
       translate([-(width - length)/2, 0, 0])
         cylinder(h=mat, r=width/2, center=true);
     }
  }
}

/*
 * Punch holes in the arms
 */
module arm_with_holes(length, width, holediam) {
    difference() {
        arm(length + width, width);
        translate([-length/2, 0, 0])
         cylinder(h=5*mat, r=holediam/2, center=true);
        translate([length/2, 0, 0])
         cylinder(h=5*mat, r=holediam/2, center=true);
    }

}
/*
 * prism module stolen from the openscad tutorial.
 */
module prism(l, w, h){
  polyhedron(
	     points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
	     faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
	     );
}
 
/*
 * A 'hook' or 'lip' for mating with a tab.
 */
module hook() {
    /* 
     * comes out of plate which is already 1*mat thick.
     * needs mat+slack clearance for shell to mate.
     * Plus mat for cross piece.
     */
    cube([10, mat, mat*3 + slack]);
    translate([0, 0, 2*mat + slack])       
      cube([10, 2*mat - slack, mat]);
    /* Close off the end */
    cube([mat, 2*mat, 2*mat + slack]);
    
}

/*
 * The plate is the main mount.
 * In this design, it has guides for the battery to fit inside
 * and the shell to fit outside of.
*/
module plate(length, wid, height) {
    // Skirt is for hook plus shell on each side.
    skirt = 3*mat;
    ll = length + 2*mat;
    ww = wid + 2*skirt; 
    cube([ll, ww, mat]);

    // side hooks to attach shell
    // Colour them green so that can be seen easily
    translate([0, skirt, 0])
        mirror([0, 1, 0])
      color("green") hook();
    translate([20, skirt, 0]) 
        mirror([0, 1, 0])
      color("green") hook();
    translate([0, wid+skirt, 0]) 
      color("green") hook();
    translate([20, wid+skirt, 0]) 
      color("green") hook();

    // Front cover.  
    // Leave room for wires to come out
    translate([0, wirewidth, 0]) 
       cube([1, wid + 2*skirt - wirewidth , height + mat]);
    translate([10, wid + skirt, 0]) 
       rotate(90) 
       prism(mat, 10, battery_height+clearance);

    // Back stop
    translate([length, mat*2, 0])
      cube([1, wid + 2*mat, height/2]);
      
}

/*
 * The 'frame' is the mounting framework with the
 * 2.55mm⌀ holes.  It's designed to clear the
 * two LEDs (charge and power) on the SwagBadge
 */
module frame(w) {
    translate([0, 0, 0.5]){
    diag= sqrt(d1^2 + d2^2);
    diag_angle = atan2(d2, d1);
    arm_with_holes(d1, w, screw);
    translate([d1/2, d2/2, 0]) 
        rotate(90)
        arm_with_holes(d2, w, screw);
    translate([0, d2/2, 0])
        rotate (diag_angle)
        arm_with_holes(diag, w, screw);
    translate([-d1/2, d2/2, 0])
        rotate(90)
        arm_with_holes(d2, w, screw);
    translate([-diag*cos(diag_angle)/4, 
        sin(diag_angle)*diag*3/4, 0]) 
        rotate(-diag_angle)
        arm_with_holes(diag/2, w, screw);
    }
}

// shell uses inside dimensions.
module shell(l, w, h) {
    // Adjust for width of material
    ll = l + 2*mat;
    ww = w + 4*mat;
    hh = h + mat;
    //top
    cube([ll, ww, mat]);
    // left side
    cube([ll, mat, hh]);
    // Right side
    translate ([0, ww, 0]) cube([ll, mat, hh]);
    // Back
    cube([1, ww, hh]);
    // Tabs to mate with hooks.
    translate([ll-10-mat, ww-mat+slack, h+slack])
      color("green") cube ([10 - mat, (2-slack)*mat, (1-slack)*mat]);
    translate([ll-30-mat, ww-mat+slack, h + slack]) cube ([10 - mat, (2-slack)*mat, (1-slack)*mat]);
    translate([ll-10-mat, 0, h+slack]) cube ([10 - mat, (2-slack)*mat, (1-slack)*mat]);
    translate([ll-30-mat, 0, h+slack]) cube ([10 - mat, (2-slack)*mat, (1-slack)*mat]);

    // triangle to partly close wirehole, supprt side.
    if (!right) {
    translate([ll - mat,wirewidth , 0]) mirror([0, 1, 0])  prism(mat, wirewidth, h);
    }
}
/*
* Join the plate and the frame.
* Move the plate as close as possible to the edge of the frame without
* covering the mounting holes
*/
union() {
  if (right) {
    translate([-wid - 6*mat +d1/2 -armwidth/2,
      -armwidth/2,
      0])
    rotate(90) mirror([0,1,0])
       plate(length, wid, battery_height + clearance);
  }
  else {
   translate([wid + 3*mat - d1/2 + armwidth, 
      -armwidth/2, 
      0])
       rotate(90)
       plate(length, wid, battery_height + clearance);
  }
    frame(armwidth);
}
translate([-d1*1.2, battery_length+1, 0])
// Use this translate to check that the dimensions are right.
/*translate([-wid -6*mat, length + 2*mat, battery_height + clearance + mat*4])   mirror([0,0,1]) */
rotate(-90)
    color("red")shell(length, wid, battery_height + clearance);


// The pintacks and washers aren't right yet.
/*
for (x=[0:1]) {
    for (y=[0:1]){
    translate([x*10, y*10-20, 0]) 
        pintack(h=9,r=2.48/2, br=2.5, bh=1, lt=0.8, lh=2);
    }
}
*/

for (x=[0:1]) {
    for (y=[0:1]){
    translate([x*10+20, y*10-20, 0]) 
        washer(2, screw+0.05, armwidth);
    }
}
