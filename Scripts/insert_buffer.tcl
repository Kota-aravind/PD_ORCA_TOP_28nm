############### get violated net name and insert buffer to driver ######################## 
proc insert_driver_buffer nn { 
	set pi  [get_object_name [get_pins [all_connected $nn -leaf] -filter "direction == out"]] 
	set bn [get_object_name [ insert_buffer $pi NBUFFX8_HVT]]
	set pil [get_attribute [get_pins $pi] location] 
	move_objects -to $pil [get_cell $bn]
	puts "diver_pin_name $pi     inserted_buffer_name : $bn " 
	} 
############################# get_violated_name and pass violated net_name to proc ####################### 
set file_name ./outputs/mcv_aco.txt 
set fh_read [open $file_name r] 
set i 0 
set m 0
set n 0 
while {[gets $fh_read line] >= 0} {
		if {[llength $line] == 5}  {
		incr i 
		puts "\n iteration : $i " 
		set net_name [lindex $line 0] 
		 set flag [catch {insert_driver_buffer $net_name}] 
		 if {$flag == 0} {
			puts "buffer inserted  successfully"  
	         	incr m
		 }  else {
			puts "failed to insert buffer" 
			incr n
		} 
		
		
	}
 
}  
legalize_placement -incremental 

puts "\n number of buffers inserted $m" 
puts "number of buffers failed to insert $n" 
