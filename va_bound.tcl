remove_voltage_area -all 
set uti 0.8
# Find Voltage area required for utilization 0.8 
	# Va = (area_of_cell_belonging_to_PD_RISC_CORE_PD) / Uti 	
	set tca 0 
	foreach_in_collection c [get_flat_cells -filter "power_domain == PD_RISC_CORE"] { 
		set ca [get_attr [get_cells $c] area] 
		set tca [expr $tca + $ca] 
	} 

	set va [expr $tca / $uti] 
	puts "va required for utilization $uti is : $va" 


# Find Height and width required for voltage area
	# Height = 10 + height_of_macro(147) + 15 
	set h [expr 10 + 147 + 15] 
	
	# Widht [ w = 	va / h] 
	set w [expr $va / $h] 
 
# Adjust co-ordinates so that voltage area is on site_rows and site_coloums using TCL 
	# n = w / 0.152
	# round n to next higher integer 
	# w = n * 0.152
 	
	# m = h / 1.672  = 190.32 = 191
	# round m to next higher integer 
	# h = m * 1.672
	set llx 5
	set lly 5 
	set urx [expr ((ceil ($w / 0.152)) * 0.152) + 5] 
	set ury [expr ((ceil ($h/1.672)) * 1.672) + 5] 

#to have a guard band on edge of core & site row modify coordinates
set new_llx [expr $llx + 5.016]
set new_lly [expr $lly + 5.016]
set new_urx [expr $urx + 5.016]
set new_ury [expr $ury + 5.016 - 1.672]

set va_box [list [list $new_llx $new_lly] [list $new_urx $new_ury]]
puts $va_box
# va_box ?
# create voltage area with these new coordinates with guard band distance {{5.0165.016}}
create_voltage_area -power_domains PD_RISC_CORE -region $va_box   -guard_band {{5.016 5.016}}

proc uti_for_va a { 
				create_utilization_configuration -include all fp -force 		
				report_utilization -of_objects [get_voltage_areas $a ] -config fp  
			} 
