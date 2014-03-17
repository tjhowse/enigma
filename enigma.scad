
// Calibrated inside diameter fudge factor
print_id_r = 0.2;
screw_head_r = 5.7/2+print_id_r;
screw_shaft_r = 2.9/2;
screw_total_z = 8.14;
screw_head_z = 2;
screw_shaft_z = screw_total_z-screw_head_z;

wall_thickness = 2;
screw_gap = 1;
screw_count = 26;
$fn = screw_count;
zff = 0.01;

contact_ring_r = (((screw_head_r*2 + screw_gap)*screw_count)/PI)/2;
contact_to_ratchet_mid = 10;
ratchet_ring_r = contact_ring_r + contact_to_ratchet_mid;

ratchet_angle = 24; // Of the angled bit.
flat_portion = 0.2; // Proportion of unit length	
ratchet_unit_length = ((ratchet_ring_r*2)*PI)/screw_count;
ratchet_angled_length = (ratchet_unit_length*(1-flat_portion))/cos(ratchet_angle);
ratchet_tooth_depth = ratchet_angled_length*sin(ratchet_angle);

pawl_y = 7;
contact_overlap = 0.3;
contact_left_countersink = 1-contact_overlap/2;
ratchet_left_z = pawl_y/2+contact_left_countersink;
contact_right_countersink = 1-contact_overlap/2;
ratchet_right_z = pawl_y/2+contact_right_countersink;
rotor_axle_r = 4+print_id_r;
wehrmacht = 1;
join_screw_r = 15;

contact_tip_clearance = 1;
rotor_mid_z = screw_shaft_z-ratchet_left_z-ratchet_right_z+screw_total_z+contact_tip_clearance+3;
thumbwheel_z = 3;
thumbwheel_r = ratchet_ring_r + 10;
thumbwheel_notch_r = ((thumbwheel_r*2*PI)/(screw_count*2))/2;
// thumbwheel_notch_r = ((thumbwheel_r*2*PI)/(screw_count*2));
thumbwheel_notch_adjust = 1.5;
thumbwheel_notch_scale_x = 0.6;
thumbwheel_notch_scale_y = 1.01;
rotor_mid_r = ratchet_ring_r+ratchet_tooth_depth/2;
// rotor_mid_z = (screw_total_z*2 - ratchet_z*2)+contact_tip_clearance;

under_rotor_clearance = 20; // This depends on where the hinge is for the lever which actuates the pawls.


module screw(big_head = 0)
{
	translate([0,0,-big_head*100]) render()
	{
		cylinder(r=screw_head_r,h=screw_head_z+big_head*100,$fn = 10);
		translate([0,0,screw_head_z+big_head*100]) cylinder(r=screw_shaft_r,h=screw_shaft_z,$fn = 10);
	}
}

module ratchet_cut(height)
{
	render()
	{
		scale([1,-1,1]) translate([ratchet_tooth_depth/2-0.4,0,0]) intersection()
		{
			translate([0,-(0.5-flat_portion)*ratchet_unit_length,0]) union()
			{
				rotate([0,0,ratchet_angle]) cube([20,ratchet_angled_length,height]);
				translate([0,-ratchet_unit_length*flat_portion,0]) cube([20,20,height]);
				
			}
			cube([10,ratchet_unit_length,height*2],center=true);
		}
	}
	// %cube([10,ratchet_unit_length,10],center=true);
}

module contact_holes()
{
	render()
	{
		for (i=[0:360/screw_count:360])
		{
			rotate([0,0,i]) translate([contact_ring_r,0,0]) rotate([180,0,0]) screw(1);
		}
	}
}

module join_holes()
{
	for (i=[0:90:360])
	{
		rotate([0,0,i]) translate([join_screw_r,0,0]) rotate([180,0,0]) screw();
	}
}

module ratchet_right()
{
	// Right side is the one with the pins.
	difference()
	{
		// cylinder(r=contact_ring_r+screw_head_r+screw_gap,h=screw_shaft_z-zff);
		cylinder(r=ratchet_ring_r+ratchet_tooth_depth/2,h=ratchet_right_z);
		translate([0,0,-screw_head_z+contact_right_countersink]) rotate([180,0,0]) contact_holes();
		for (i=[0:360/screw_count:360])
		{
			rotate([0,0,i]) translate([ratchet_ring_r,0,-zff]) ratchet_cut(ratchet_right_z+zff*2);
		}
		translate([0,0,-zff]) rotate([180,0,45]) join_holes();
		cylinder(r=rotor_axle_r,h=ratchet_right_z);
	}
}

module rotor_mid()
{
	difference()
	{
		union()
		{
			difference()
			{
				union()
				{
					rotate([0,0,(360/screw_count)/2]) cylinder(r=thumbwheel_r,h=thumbwheel_z);
					for (i=[0:360/screw_count:360])
					{
						rotate([0,0,i+(180/screw_count)])
							translate([thumbwheel_r,0,-zff])
								scale([thumbwheel_notch_scale_x,thumbwheel_notch_scale_y,1])
									cylinder(r=thumbwheel_notch_r-thumbwheel_notch_adjust,h=thumbwheel_z+2*zff);
					}
				}
				for (i=[0:360/screw_count:360])
				{
					rotate([0,0,i])
						translate([thumbwheel_r,0,-zff])
							scale([thumbwheel_notch_scale_x,thumbwheel_notch_scale_y,1])
								cylinder(r=thumbwheel_notch_r+thumbwheel_notch_adjust,h=thumbwheel_z+2*zff);
				}
			}	
			translate([0,0,thumbwheel_z]) cylinder(r=rotor_mid_r,h=rotor_mid_z-thumbwheel_z);
			
			// cylinder(r=rotor_axle_r+wall_thickness,h=rotor_mid_z+2*zff);
		}
		translate([0,0,-zff]) cylinder(r=rotor_mid_r-2*wall_thickness,h=rotor_mid_z+2*zff);
	}
	rotor_mid_spokes();
}

module rotor_mid_spokes()
{
	difference()
	{
		union()
		{
			for (i=[0:360/8:360])
			{
				rotate([0,0,i]) translate([join_screw_r,0,0]) cylinder(r=screw_shaft_r+wall_thickness,h=rotor_mid_z);
				rotate([0,0,i]) translate([0,-wall_thickness/2,0]) cube([rotor_mid_r-wall_thickness,wall_thickness,rotor_mid_z/2]);
			}
			cylinder(r=rotor_axle_r+wall_thickness,h=rotor_mid_z);
		}
		for (i=[0:360/8:360])
		{
			rotate([0,0,i]) translate([join_screw_r,0,0]) cylinder(r=screw_shaft_r,h=rotor_mid_z);
		}
		translate([0,0,-zff]) #cylinder(r=rotor_axle_r,h=rotor_mid_z+2*zff);
	}
}


module ratchet_left()
{
	// Left side is the one with the pads.
	difference()
	{
		// cylinder(r=contact_ring_r+screw_head_r+screw_gap,h=screw_shaft_z-zff);
		cylinder(r=ratchet_ring_r+ratchet_tooth_depth/2,h=ratchet_left_z);
		translate([0,0,ratchet_left_z+zff-contact_left_countersink]) contact_holes();
		rotate([0,0,0]) translate([ratchet_ring_r,0,-zff]) ratchet_cut(ratchet_left_z+zff*2);
		if (wehrmacht == 1)
		{
			rotate([0,0,180]) translate([ratchet_ring_r,0,-zff]) ratchet_cut(ratchet_left_z+zff*2);
		}
		translate([0,0,ratchet_left_z+zff]) join_holes();
		cylinder(r=rotor_axle_r,h=ratchet_left_z);
	}
}

module rotor_assemble(explode = 0)
{
	ratchet_right();
	translate([explode,explode,ratchet_right_z+explode]) rotor_mid();
	translate([2*explode,2*explode,rotor_mid_z+ratchet_left_z+2*explode]) ratchet_left();

}

// ratchet_cut(screw_shaft_z);
// rotate([180,0,0]) ratchet_right();
// ratchet_left();
// ratchet_right();
rotor_assemble(20);
// rotor_mid();