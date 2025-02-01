// A box for a raspberry pi pico with an SSH1306 display.
// two holes on the front, one for the USB and one for an 
// RJ-11 jack. 

$fn=50; // "resulution" of the circular shapes

// This was originally built to hold some key switches, it could be
// simplified.

// distance between wells
wellSpacing = 6;
keySide = 14;

// wall depth for base
wall = 1.5;
// heigth of base
bottomH = 23;

rows=2;
cols=4;
baseW = wellSpacing + cols * (wellSpacing+keySide);
baseH = wellSpacing + rows * (wellSpacing+keySide);


// radius for rounding the base box
roundR = 1.5;


// studs and holes for screws or posts that will hold a pico pi
module picoSupport() {
    h = 8;
    union() {
        color([0,1,0]) {
            difference (){
                union() {
                    translate([45,0,0]) cube([14, 15, h]); //base-back
                    cube([10, 15, h]); //base-front
                    translate([53,2.5,h])  cube([5,10,5]); //backstop
                }
                translate([3,1.5,0]) {
                    translate([0, 0, 0]) cylinder(h=10, d=2);
                    translate([0, 11.5, 0]) cylinder(h=10, d=2);
                }
                translate([50,1.5,0]) {
                    translate([0, 0, 0]) cylinder(h=15, d=2);
                    translate([0, 11.5, 0]) cylinder(h=15, d=2);
             
                }
            }
        }
    }
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
            // cut out the middle
            translate([wall,wall, wall]) {
                cube([baseW, baseH, bottomH]);
            }
        }
    }
}    


// Create the bottom container, on which the top() will be placed
module main() {
    debug = false;
    difference() {
            difference() {
                bottom();
                // make a hole for the usb plub
                translate([-10, wall+23, 5*wall]) {
                    cube([13, 19, 10]);
                }
            }        
    }
    // add supports for the pi, behind the USB hole
    translate([2.5-wall, 25+wall, 0]) {
        picoSupport();
    }
}

difference() {
    main();
    // cut out the RJ-11 hole
    translate([-2.5,4,2])color([0.5,0.8,0.2])cube([5.25, 13, 25]);
}
// add two tabs to better hold in the RJ11
translate([-1.5,17,5])cube([4,3,10]);
translate([-1.5,2,5])cube([4,2,10]);