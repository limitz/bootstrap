/*[ Visualization ]*/

//Explode
explode = 1; //[1:0.1:2]

//Bed Power
m=6; //[4,5,6,7,8]

module profile3030(z, center=true) 
{
    color("lightgray")
        cube([30,30,z], center=center);
}

module profile3060(z, center=true) 
{
    color("lightgray")
        cube([30,60,z], center=center);
}

module sfu1204(z)
{
    color("darkgray")
        cylinder(z, 12, 12, center=true);
    color("silver")
        translate([0,0,-20]) // bed is raised
            cube([50, 30, 36], center=true);
    color("black")
        for (j=[-1,1])
            translate([0,0,j*(z/2-15)])
                translate([-30,-22,-10])
                    union() {
                        cube([60,32.5,20]);
                        translate([7.5,0,0])
                            cube([45,43,20]);
                    }       
}

module hgr15r(y)
{
    color("darkgray")
        translate([0,0,7.5])
            cube([15,y,15],center=true);
}

module qhw15cc()
{
    difference()
    {
        union()
        {
            translate([0,0,7.5+4])
            {
                color("green") 
                    cube([34,61.2,24-4-0.5],center=true);
                color("red")
                    cube([33,61.4,24-4-1],center=true);
            }
            translate([0,0,7.5+4+5])
                color("silver") 
                    cube([47, 39.4, 14-4], center=true);
            
        }
        for (x=[-19,19]) for (y=[-15,15])
            translate([x,y,0])
                cylinder(50, r=2, center=true);
    }
}

module bevel_xy_cube(size, bevel=10)
{
    hull() 
    {
        cube([size[0], size[1]-bevel, size[2]], center=true);
        cube([size[0]-bevel, size[1], size[2]], center=true);
    }
}

module nema17(h)
{
    color("black")
        translate([0,0,h/2])
            bevel_xy_cube([42,42,h]);
    color("silver") 
    {
        translate([0,0,4.9])
            bevel_xy_cube([42.3,42.3,10]);
        translate([0,0,h-5])
        {
            bevel_xy_cube([42.3,42.3,10.4]);
            cylinder(12, d=22, center=true);
        }
    }
    color("silver")
        translate([0,0,(h+20)/2])
            cylinder(h+20, d=5, center=true);
}
module nema17_mount(motor_h=40)
{
    translate([0,-5,25.5])
    rotate([-90,0,0])
    color("black")
        difference()
        {
            cube([50,53,51], center=true);
            translate([0,2.9,2.9])
                    cube([50.2,53.2,51.2], center=true);
            union()
            {
                
                for (x=[-15,15])
                    hull()
                    {
                        for (y=[-15,15])
                            translate([x,y,0])
                                cylinder(52, d=4.2, center=true);
                    }
                translate([0,0,5])
                {
                    rotate([90,0,0])
                        cylinder(55, d=22.1, center=true);
                    for (x=[-15.5,15.5], y=[-15.5,15.5])
                        rotate([90,0,0])
                            translate([x,y,0])
                                cylinder(55, d=3.5,center=true);
                }
            }
        }
        
    translate([0,0,49-motor_h])
        nema17(motor_h);
}



sfu_dist_x = 670;
sfu_dist_y = 710;

build_plate_x = 600;
build_plate_y = 600;

pivot_dx = (sfu_dist_x - build_plate_x) / 2;
pivot_dy = (sfu_dist_y - build_plate_y) / 2;

pivot_points = [
    [-pivot_dx, -pivot_dy],
    [-pivot_dx, build_plate_y+pivot_dy],
    [build_plate_x+pivot_dx, build_plate_y+pivot_dy],
    [build_plate_x+pivot_dx, -pivot_dy]
];

block_to_plate = (sfu_dist_y/2 - 15) - 670/2;
echo(block_to_plate)
echo(pivot_points);

outset = 485;
inset = outset - 15 - 50 - 15-2;

// frame
// bottom + top
for(i=[-390,390], j=[30,590])
    translate([0,i,j] * explode)
        rotate([90,0,90])
            profile3060(1000);
            
for (i=[-outset,-inset, inset, outset], j=[30,590])
    translate([i,0,j] * explode)
        rotate([90,0,0])
            profile3060(750);
       
// middle
for (i=[-485,485], j=[-200,200])            
    translate([i,j,310] * explode)
        profile3060(500);

for (i=[-485,485], j=[-390,390])            
    translate([i,j,310] * explode)
        profile3030(500);

for (i=[-265,265]) 
    translate([i,390,310] * explode)
        profile3030(500);

for (i=[-265,265]) 
    translate([i,-390,310] * explode)
        rotate([0,0,90])
            profile3060(500);

// Y motors
for(i=[-1,1], j=[-1,1])
    translate([i*(outset-25-11),j*(390-25-15),576-8] * explode)
        rotate([0,0,i*-90])
            nema17_mount(40);

// Z motors
for(i=[-1,1], j=[-1,1])
    translate([i*(outset-25-11-65-28),j*(390-25-15-100),50] * explode)
        rotate([0,180,i*90])
            nema17_mount(40);
  
// ball screws
for (i=[-1,1], j=[-1,1])
    translate([i*(sfu_dist_x/2), j*(sfu_dist_y/2),300] * explode)
        rotate([0,0,90+j*90])
            sfu1204(600);


translate([0,0,330])
{
    // bed
    color("gray")
    {
        for(i=[-320,320])
            translate([0,i,-30] * explode)
                rotate([90,0,90])
                    profile3060(750);   

       for(i=[-1,-0.7,0,0.7,1])
            translate([i*360,0,-30] * explode)
                rotate([90,0,0])
                    profile3060(610);   

    }

    // insulation
    color("yellow")
    {
        translate([0,0,1] * explode^m)
            cube([750,670,2], center=true);
    }

    // heater
    color("orange")
    {
        translate([0,0,2+1] * explode^m)
            cube([600,600,2], center=true);
    }

    // heatsink
    color("lightgray")
    {
        translate([0,0,2+2+2.5] * explode^m)
            cube([750,670,5], center=true);
    }

    // build plate
    color("#444444")
    {
        translate([0,0,5+2+2+1] * explode^m)
            cube([600,600,2], center=true);
    }
}
// rails
for (i=[-inset, inset])            
    translate([i,0,590] * explode)
        translate([0,0,30])
        {
            hgr15r(800);
            qhw15cc();
        }
        
// x axis
translate([0,-15,500+60+60+24+15] * explode)
{
    for (i = [-400,400])
        translate([i,-36,46] * explode)
            rotate([90,0,180])
                nema17_mount(30);
        
    rotate([0,90,0])
        profile3030(1000, center=true);
    translate([0,15,0] * explode)
        rotate([270,90,0])
        {
            hgr15r(800);
            qhw15cc();
        }
}