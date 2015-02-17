include <config.scad>
use <GDMUtils.scad>
use <joiners.scad>


module rail_lifter_segment()
{
	joiner_length = 10;
	side_joiner_len = 10;

	xlen = motor_rail_length/2-25;
	ylen = (rail_width-motor_mount_spacing)/2;
	hlen = sqrt(xlen*xlen+ylen*ylen);
	ang = atan2(ylen,hlen);

	color("SpringGreen")
	prerender(convexity=20)
	union() {
		difference() {
			union() {
				// Bottom.
				translate([0,0,rail_thick/2]) {
					union() {
						yrot(90) sparse_strut(h=rail_width, l=motor_rail_length, thick=rail_thick, maxang=45, strut=10, max_bridge=500);
						grid_of(count=2, spacing=motor_mount_spacing) {
							cube(size=[joiner_width, motor_rail_length, rail_thick], center=true);
						}
					}
				}

				// Walls.
				zrot_copies([0, 180]) {
					translate([(rail_spacing/2+joiner_width/2), 0, (rail_height+3)/2]) {
						if (wall_style == "crossbeams")
							sparse_strut(h=rail_height+3, l=motor_rail_length-2*joiner_length, thick=joiner_width, strut=5);
						if (wall_style == "thinwall")
							thinning_wall(h=rail_height+3, l=motor_rail_length-2*joiner_length, thick=joiner_width, strut=5, bracing=false);
						if (wall_style == "corrugated")
							corrugated_wall(h=rail_height+3, l=motor_rail_length-2*joiner_length, thick=joiner_width, strut=5);
					}
				}

				// Rail backing.
				grid_of(count=2, spacing=rail_spacing+joiner_width)
					translate([0,0,rail_height+groove_height/2])
						chamfer(size=[joiner_width, motor_rail_length, groove_height], chamfer=1, edges=[[1,1,0,0], [1,1,0,0], [0,0,0,0]])
							cube(size=[joiner_width, motor_rail_length, groove_height], center=true);

				// Top side support
				translate([0, (motor_rail_length-18)/2, (rail_height-15)/2]) {
					zrot(90) sparse_strut(h=rail_height-15, l=rail_width, thick=5, strut=5);
					translate([0, 0, -(rail_height-15-rail_thick)/2]) {
						cube(size=[rail_width, 5, rail_thick], center=true);
					}
				}

				// Bottom side support
				translate([0, -(motor_rail_length-18)/2, (rail_height+groove_height)/2]) {
					zrot(90) sparse_strut(h=rail_height+groove_height, l=rail_width-joiner_width, thick=5, strut=6);
					translate([0, 0, -(rail_height+groove_height-rail_thick)/2]) {
						cube(size=[rail_width, 5, rail_thick], center=true);
					}
				}

				// Motor mount joiners.
				translate([0, 0, rail_height+groove_height/2]) {
					joiner_pair(spacing=motor_mount_spacing, h=rail_height, w=joiner_width, l=15, a=joiner_angle);
				}
				grid_of(count=2, spacing=motor_mount_spacing) {
					translate([0, -15/2, rail_height/4+groove_height/4]) {
						cube(size=[joiner_width, 15, rail_height/2+groove_height/2], center=true);
					}
				}

				// Motor mount supports.
				mirror_copy([1, 0, 0]) {
					translate([(rail_width+motor_mount_spacing)/4-2, -motor_rail_length/4, (rail_height+groove_height)/2]) {
						zrot(ang) {
							sparse_strut(h=rail_height+groove_height, l=hlen, thick=7.5, strut=5);
							translate([0, 0, -(rail_height+groove_height-rail_thick)/2]) {
								cube(size=[7.5, hlen, rail_thick], center=true);
							}
						}
					}
				}
			}

			// Clear space for joiners.
			translate([0,0,rail_height/2]) {
				joiner_quad_clear(xspacing=rail_spacing+joiner_width, yspacing=motor_rail_length, h=rail_height, w=joiner_width, clearance=5, a=joiner_angle);
			}

			// Shrinkage stress relief
			translate([0, 0, rail_thick/2]) {
				grid_of(count=[1, 5], spacing=[0, 16]) {
					cube(size=[rail_width+1, 1, rail_thick-2], center=true);
				}
				grid_of(count=[7, 2], spacing=[15, motor_rail_length-10]) {
					cube(size=[1, 60, rail_thick-2], center=true);
				}
			}

			// Clear space for side mount joiners.
			zrot_copies([0,180]) {
				translate([rail_width/2-5, 0, 0]) {
					translate([side_joiner_len+joiner_width/2, 0, rail_height/2/2]) {
						translate([0, -platform_length/4, 0]) {
							zrot(-90) half_joiner_clear(h=rail_height/2, w=joiner_width, l=side_joiner_len, a=joiner_angle);
						}
						translate([0, platform_length/4, 0]) {
							zrot(-90) half_joiner_clear(h=rail_height/2, w=joiner_width, l=side_joiner_len, a=joiner_angle, slop=printer_slop);
						}
					}
				}
			}
		}

		// Snap-tab joiners.
		translate([0,0,rail_height/2]) {
			joiner_quad(xspacing=rail_spacing+joiner_width, yspacing=motor_rail_length, h=rail_height, w=joiner_width, l=13, a=joiner_angle);
		}

		// Side mount joiners.
		zrot_copies([0,180]) {
			translate([rail_width/2-5, 0, 0]) {
				translate([side_joiner_len+joiner_width/2, 0, rail_height/2/2]) {
					translate([0, -side_mount_spacing/2, 0]) {
						zrot(-90) {
							chamfer(chamfer=joiner_width/3, size=[joiner_width, side_joiner_len*2, rail_height/2], edges=[[0,0,0,0], [1,1,0,0], [0,0,0,0]]) {
								half_joiner(h=rail_height/2, w=joiner_width, l=side_joiner_len, a=joiner_angle);
							}
						}
					}
					translate([0, side_mount_spacing/2, 0]) {
						zrot(-90) {
							chamfer(chamfer=joiner_width/3, size=[joiner_width, side_joiner_len*2, rail_height/2], edges=[[0,0,0,0], [1,1,0,0], [0,0,0,0]]) {
								half_joiner2(h=rail_height/2, w=joiner_width, l=side_joiner_len, a=joiner_angle, slop=printer_slop);
							}
						}
					}
				}
			}
		}
	}
}
//!rail_lifter_segment();



module rail_lifter_segment_parts() { // make me
	zrot(90) rail_lifter_segment();
}


rail_lifter_segment_parts();



// vim: noexpandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap
