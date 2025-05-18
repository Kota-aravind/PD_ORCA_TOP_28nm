# Find violated nets from mcv file 
###################### Proc  started ##########################
proc upsize_cell nn {
set nnn [get_nets -of_objects [get_pins $nn ]]
set dn [get_object_name [get_cells -of_objects  [get_pins  [all_connected $nnn -leaf ] -filter "direction == out"]]] 
set drn [get_attribut [get_cell $dn] ref_name ] 
puts "driver_name : $dn old_ref_name : $drn" 
regexp -nocase {(.+X)([0-9]+)(.+)} $drn temp rn ds vt
	# NANDX2_HVT # NANDX - rn # 2 - ds 	# _HVT - vt 
	# 0 -- 1 # 1 -- 2 # 2 -- 4 # 4 -- 
	if {$ds == 0} { 
		set ds 1
	} else {
		set ds [expr $ds * 2] 
	} 
# AOI222X2_RVT
size_cell $dn $rn$ds$vt
set drn [get_attribut [get_cell $dn] ref_name ]  
puts "driver_name : $dn new_ref_name : $drn " 
} 
##################### proc ends ##############################

set file_name ./outputs/mtv.txt 
set fh_read [open $file_name r] 
set i 0 
set m 0
set n 0 
while {[gets $fh_read line] >= 0} {
		if {[llength $line] == 8}  {
		incr i 
		puts "\n iteration : $i " 
		set net_name [lindex $line 0] 
		 set flag [catch {upsize_cell $net_name}] 
		 if {$flag == 0} {
			puts "upsized successfully"  
	         	incr m
		 }  else {
			puts "failed to upsize" 
			incr n
		} 
		
		
	}
 
}  

puts "\n number of drivers upsized $m" 
puts "number of drivers failed to upsize $n" 
