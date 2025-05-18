remove_pin_guides -all 
# Open file in read mode 
set fh_read [open /home/deepaksn/PD_LAB/PD/scripts/port_placement.tcl r]

# sdram_clk 0.1430 702.6800

while {[gets $fh_read line] >= 0} {
set po [lindex $line 0] 
set lo [lrange $line 1 2] 

set_individual_pin_constraints -port $po -location $lo -allowed_layers {M5 M6} 
} 
 
place_pins -ports [get_ports] 
close $fh_read 
