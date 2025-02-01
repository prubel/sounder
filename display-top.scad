// The top of display.scad
// A lid and a holder for a SSD1306 display

// model "resolution"
$fn=50;

// as with the other code, this was originally part of a keyboard. Feel free
// to fix it up

// distance between key wells
wellSpacing = 6;
// size of a key switch
keySide = 14;

// how deep to cut into the lid
topToLip = 4;

// rows of keys
rows=2;
// columns of keys
cols=4;

// wall depth 
wall = 1.5;
// heigth of base, used for chopping things off
bottomH = 23;

baseW = wellSpacing + cols * (wellSpacing+keySide);
baseH = wellSpacing + rows * (wellSpacing+keySide);

// cut out a hole that fits a key switch
module switchHole() {
 cube ([keySide, keySide, keySide]);
}


lip = 8;
offS = 1;
// rounded top rectangle
module rTop() {
    hull() {
        difference() {
            union() {
                // round out the edge by putting a sphere on each corner
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
            // chop off the bottom of the sphers/tubes
            translate([-0.25*baseW, -0.25*baseH,3-bottomH]) {
                cube([1.5*baseW,1.5*baseH,bottomH]);
            }
        } //difference
    } //hull    
}

// cubes laid on in the correct grid, used in a difference to make 
// space for the switches
module wells() {
    for (i = [1:1:2]) {
        yoff = wellSpacing + ((i-1) * (wellSpacing+keySide));
        for (j = [1:1:1]) {
            xoff = wellSpacing + ((j-1) * (wellSpacing + keySide));
            translate([xoff, yoff, 0]) {
                switchHole();
            }
        }
    }
}

// top is the rounded top with 2 switch holes and a base
module top() {
    difference() {
        union() {
            rTop();
            // add a bottom rectangle, to fit into the base
            translate([0.5,0.5,0]) color([1,0,1])cube([baseW-0.5, baseH-0.5, topToLip-1]);
        }
        // cut into the rTop, but not all the way through, inset the screen and keys
        translate([2*wall, 2*wall, 2]) {
            cube([baseW-4*wall, baseH-4*wall, bottomH]);
        }
        // the two switch holes
        translate([0, 0, -3]) {
            color([0.25,0.25,0]) wells();
        }
    }    
}


// a flattened cube with 4 supports that match the SSD1306 screw holes
module display_nubs() {
    cube([35,35,2]);
    translate([5,5,3]) {  
    for (i = [0:23:23]) {
          for (j = [0:23:23]) {
              translate([i,j,0]) {
                  cylinder(2, r=2.5, center=true);
              }
          }
      }
    }
}

// the top of the "sandwich" for the SSD1306
module display_holder() {
    difference() {
        display_nubs();
        // diff out screw holes
        for (i = [0:23:23]) {
            for (j = [0:23:23]) {
                translate([5+i,5+j,0]) {
                    cylinder(10, r=1.5, center=true);
                }
            }
        }
        // cut the hole so we can see the display
        translate([4,9.5,-1]) cube([25.5,16,5]);
        // orientation notch
        translate([17,36,0]) cylinder(5, r=3,center=true);
    }
}


// dTop is the top with display infrastructure and LED holes
module dTop() {
    difference() {
        union() {
            top();
            // screw supports for the display
            for (i = [0:23:23]) {
                  for (j = [0:23:23]) {
                      translate([50+i,12.5+j,3]) {
                          cylinder(2, r=2.5, center=true);
                      }
                  }
            }
        }
        // screw holes. needs to not be in the above, because this is a difference
        for (i = [0:23:23]) {
                for (j = [0:23:23]) {
                    translate([50+i,12.5+j,-5]) {
                        cylinder(20, d=1.95, center=true);
                    }
                }
        }
        // cutout for display
        translate([47.5,16,-5]) cube([28,16,20]);
        translate([53.5,11,-5]) cube([15,25,20]);
        
        // led hole
        translate([35,23,-5]) cylinder(20, d=6,center=true);    
    }    
}

translate([0,60,0]) display_holder();
translate([0,120,0])dTop();
