/*
* This version doesn't work.
* --- Pins are too large for holes, and do not fit.
* --- Clearance between hook and guides prints too small for 
*     shell to mate with plate.
* --- Plate obscures charge lamp --- can it be made smaller?
*/
/*
 * Licence:
 * Copyright 2021 Peter Chubb
 * Licensed under CC-By-SA-NC 4.0
 * https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
 */

/* Adjust for your battery size */
battery_width = 26;
battery_length = 45;
battery_height = 9;
/* These are the centres for the 2.5⌀ mounting holes */
d1= 72;
d2 = 31;
armwidth=5;
/* the mounting holes are for M2.5 screws.
 * Use slightly more than that, both for clearance, and 
 * because rendering for printing usually undersizes holes.
 */
screw=2.55;
/*
 * How much space to allow around the battery.
 * Fill it with foam rubber after making, if it's too big.
 */
clearance = 1.5;
// Material thckness
mat = 1;
// Size of skirt around outside of shell, for hooks.
skirt = 2; 
// Allowance for spaces so that things mate firmly but not too tightly.
slack = 0.2;
len = battery_length + clearance;
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
module arm_with_holes(len, width, holediam) {
    difference() {
        arm(len + width, width);
        translate([-len/2, 0, 0])
         cylinder(h=5*mat, r=holediam/2,center=true);
        translate([len/2, 0, 0])
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
 * In this design, it has guides for the battery to fit inside, 
 * and the shell to fit outside of.
 * It'll end up 2*(skirt + mat) wider, and 2*mat longer than
 * requested.
*/
module plate(len, wid, height) {
    wirewidth=8;
    slack = 0.2;
    thickness = mat;
    ll = len + 2*mat;
    ww = wid + 2*(skirt + 1 * mat); 
    ss = skirt +  mat;
    cube([ll, ww, mat]);

    // small guides for top and battery
    translate([len - 10 - ss, ss, 0])
        cube([10, 1, (height-clearance)/3]);
    translate([0, ss, 0])
        cube([10, 1, (height - clearance)/3]);
    translate([0, wid + skirt, 0])
        cube([10, 1, (height-clearance)/3]);
    translate([len - 10 - ss, wid + skirt, 0])
        cube([10, 1, (height-clearance)/3]);

    // side hooks to attach shell
    hook();
    translate([20, 0, 0]) 
      hook();
    translate([0, wid+2*ss, 0]) 
      mirror([0,1,0]) hook();
    translate([20, wid+2*ss, 0]) 
      mirror([0,1,0]) hook();

    // Front cover.  
    // Leave room for wires to come out
    translate([0, wirewidth, 0]) 
      cube([1, wid + 4 - wirewidth , height+1]);translate([10, wid + skirt,0]) 
      rotate(90) 
      prism(mat, 10, battery_height+clearance);
      
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
    ww = w + mat;
    hh = h + mat;
    ss = skirt + mat;
    //top
    cube([ll, ww, mat]);
    // left side
    cube([ll, mat, hh]);
    // Right side
    translate ([0, ww, 0]) cube([ll, mat, hh]);
    // Back
    cube([1, ww, hh]);
    // Tabs to mate with hooks.
    translate([ll-10, ww, h]) cube ([10 - mat, 1.8*mat, 0.8*mat]);
    translate([ll-30, ww, h]) cube ([10 - mat, 1.8*mat, 0.8*mat]);
    translate([ll-10, -skirt, h]) cube ([10 - mat, 1.8*mat, 0.8*mat]);
    translate([ll-30, - skirt, h]) cube ([10 - mat, 1.8*mat, 0.8*mat]);

}
/*
* Join the plate and the frame.
* Move the plate as close as possible to the edge of the frame without
* covering the mounting holes
*/
union() {
   translate([(d1/2)-len + 2*armwidth, 0, 0])
       rotate(90)
       plate(len, wid, battery_height + clearance);
    frame(armwidth);
}
translate([-75, battery_length+1, 0])
// Use this translate to check that the dimensions are right.
//translate([-wid - skirt - mat +0.5, len, 0])   
rotate(-90)
    shell(len, wid, battery_height + clearance);


// The pintacks and washers aren't right yet.
for (x=[0:1]) {
    for (y=[0:1]){
    translate([x*10, y*10-20, 0]) 
        pintack(h=9,r=2.48/2, br=2.5, bh=1, lt=0.8, lh=2);
    }
}

for (x=[0:1]) {
    for (y=[0:1]){
    translate([x*10+20, y*10-20, 0]) 
        washer(2, screw+0.05, armwidth);
    }
}
