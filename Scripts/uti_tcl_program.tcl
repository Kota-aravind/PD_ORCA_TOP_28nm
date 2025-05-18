# Formula method 
# uti = (Total_cell_area / Total_core_area)

# Find total cell area 
set tca 0 

foreach_in_collection c [get_flat_cells] {
	set a [get_attribute [get_cells $c] area] 
	set tca [expr $tca + $a] 
		
} 

puts "total cell area $tca"

# Find total_core_area
set tcoa [get_attribute [get_core_area] area]  
puts "total core_area is $tcoa" 

# Utilzation 
set uti [expr $tca / $tcoa] 
set uti_r [format "%.3f" $uti] 
puts "Utilization : $uti_r" 



