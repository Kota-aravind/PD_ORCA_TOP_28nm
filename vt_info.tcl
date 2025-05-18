# %vt of Vt cells in design .
#
# foreach_loop will take each and every cell at a time and it will execute the loop 
#cell_names=  {U1 U2 U3 U4 U5} 
# NAND2X2_HVT NOR2X4_RVT 
set i 0
set j 0
set k 0 
foreach_in_collection c [get_flat_cells] {
	set rf [get_attr [get_cells $c] ref_name ] 
		if {[regexp -nocase {HVT} $rf]} {
			incr i 
		} elseif {[regexp -nocase {RVT} $rf]} {
			incr j 

		} elseif {[regexp -nocase {LVT} $rf]} {
			incr k 
		} 
} 

puts "no of HVT cells are : $i"
puts "no of RVT cells are : $j"
puts "no of LVT cells are : $k"

set tc [expr $i + $j + $k + 0.0] 
puts "total_cells_tested : $tc"

# Percentage of HVT 
# (i / tc) * 100 
set phvt [format "%.2f" [expr ($i / $tc) * 100]] 
puts "percentage of HVT cells is : $phvt"
 
# Percentage of RVT 
# (j / tc) * 100 
set prvt [format "%.2f" [expr ($j / $tc) * 100]] 
puts "percentage of RVT cells is : $prvt" 

# Percentage of LVT 
# (k / tc) * 100 
set plvt [format "%.2f" [expr ($k / $tc) * 100]] 
puts "percentage of LVT cells is : $plvt" 







