// An enclosure for an HC-SR04 ultrasonic sounder
// It has a cutout for the rj-11 jack to connect it 
// to the rest of the system.

$fn=50;

baseW = 60;
baseH = 45;

// distance between wells
wellSpacing = 6;

roundR = 1.5;
keySide = 14;

// the depth of the top "key holder"
baseDepth = 1;
topToLip = 4;

rows=2;
cols=4;

// wall depth for base
wall = 2.25;//1.5; //1.5
// heigth of base
bottomH = 23;

module switchHole() {
 cube ([keySide, keySide, keySide]);
}


module screwTab() {
   cylinder(h=baseDepth, d=7);
}

module screwHole() {
    cylinder(h=baseDepth, d=3);
}


lip = 8;
offS = 1;
// rounded top 
module rTop() {
        hull() {
            difference() {
                union() {
                    // round out the edge
                    translate([offS,offS,3]) rotate([0,0, -45]) scale([0.7,1])sphere(5);
                    translate([baseW-offS, offS, 3]) rotate([0,0, 45]) scale([0.7,1])sphere(5);
                    translate([baseW-offS,baseH-offS, ,3]) rotate([0,0, -45]) scale([0.7,1])sphere(5);
                    translate([offS, baseH-offS,3]) rotate([0,0, 45]) scale([0.7,1])sphere(5);
                    
                        // one set of parallel tubes
                    rotate(a=[-90,0,0]) {
                        translate([2, 0, 2]) {
                            linear_extrude(height=baseH-4, center=false) {
                                scale([0.5, 1]) circle(lip);
                            } 
                        }
                        translate([baseW-2, 0, 2]) {
                            linear_extrude(height=baseH-4, center=false) {
                                scale([0.5, 1]) circle(lip);
                            } 
                        }
                    }
                    
                    
                    // other set of parallel tubes
                    rotate(a=[0,90,0]) {
                        translate([0, 2, 2]) {
                            linear_extrude(height=baseW-4, center=false) {
                                scale([1, 0.5]) circle(lip);
                            } 
                        }
                        translate([0, baseH-2, 2]) {
                            linear_extrude(height=baseW-4, center=false) {
                                scale([1, 0.5]) circle(lip);
                            } 
                        }
                    }   
                } // end union
                // chop off the bottom
                translate([-0.25*baseW, -0.25*baseH,3-bottomH]) {
                    cube([1.5*baseW,1.5*baseH,bottomH]);
                }
            } //difference
        } //hull
    
    
}


module HCSR04() {
    xd = 41/2; // this seems to be a bit off!
    yd = 18/2; 
    ch = 10; // completely hide sounders
    // ch = 5; out a bit
    pcenter = [45/2,10,0];
    difference() {
        union () {
            translate([-1.5,-1.5,0]) cube([48,23,1.5]);
            cube([45,20,1.5]);
            translate(pcenter) {
                translate([-xd,-yd,0]) cylinder(h=ch, d=4);
                translate([-xd,yd,0]) cylinder(h=ch, d=4);
                translate([xd,-yd,0]) cylinder(h=ch, d=4);
                translate([xd,yd,0]) cylinder(h=ch, d=4);
            }
        }
        translate(pcenter) {
            color([0.2,0.4,0.5])translate([-13,0,0]) cylinder(h=10, d=17.5);
            color([0.5,0.4,0.8])translate([13,0,0]) cylinder(h=10, d=17.5);
            // screw holes in supports
            translate([-xd,-yd,2]) cylinder(h=ch, d=2);
            translate([-xd,yd,2]) cylinder(h=ch, d=2);
            translate([xd,-yd,2]) cylinder(h=ch, d=2);
            translate([xd,yd,2]) cylinder(h=ch, d=2);
        }
    }
}

pgH = 1;
bd = 6; //baseDepth
module top() {
    
    difference() {
        
        union() {
            rTop();
            cube([baseW,baseH,3]); // snug to fit into bottom portion
        }
        translate([5,10,0]) cube([45,20,25]);
        translate([5,5,-2]) cube([45,30,7]);
    }
        translate([5,30,8]) rotate([180,0,0]) HCSR04();
}


// create a box without sharp edges, the main portion of bottom
module rounded_box(x, y, z, radius){
    hull(){
        for (i = [0, x]) {
            for (j = [0, y]) {
                translate([i, j, 0]) {
                    cylinder(r=radius, h=z);
                }
            }
        }
    }
}

// the base of main
module bottom() {
    color([1,0,0]) {
            difference () {
                rounded_box(baseW+2*wall, baseH+2*wall, bottomH, roundR);
                //cube([baseW+2*wall, baseH+2*wall, bottomH]);
                
                //center all inside lip
                translate([wall+2,wall+2, wall]) {
                    cube([baseW-topToLip, baseH-topToLip, bottomH]);
                }
                // twice for a lip:
                // below the lip
                translate([wall,wall, wall]) {
                    cube([baseW, baseH, bottomH]);
                }
            }
        }
        // support studs
    }    


//display



module rounded_box(x, y, z, radius){
    hull(){
        for (i = [0, x]) {
            for (j = [0, y]) {
                translate([i, j, 0]) {
                    cylinder(r=radius, h=z);
                }
            }
        }
    }
}
module bottom() {
    color([1,0,0]) {
            difference () {
                rounded_box(baseW+2*wall, baseH+2*wall, bottomH, roundR);
                //cube([baseW+2*wall, baseH+2*wall, bottomH]);
                
                //center all inside lip
                translate([wall+2,wall+2, wall]) {
                    cube([baseW-topToLip, baseH-topToLip, bottomH]);
                }
                // twice for a lip:
                // below the lip
                translate([wall,wall, wall]) {
                    cube([baseW, baseH, bottomH]);
                }
            }
        }
        // support studs
    } 


difference() {
    bottom();
    // cut out the rj-11 hole
    translate([-2.5,17,2])color([0.5,0.8,0.2])cube([5.25, 13, 25]);
}

    
translate([0,120,0])rotate([180,0,0]) translate([0,0,-8]) top();
