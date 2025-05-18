
if {0} {
# To find cells present in clock path of sdram_clk
get_attribute [get_cells -filter "is_combinational || is_integrated_clock_gating_cell" [all_fanout -from [get_ports sdram_clk] -only_cells -flat ] ] ref_name

# Script to find level of clock gating cell 
set i 0
set a [get_object_name [all_fanin -to I_PCI_TOP/I_PCI_CORE/pad_out_buf_reg[26]/CLK -flat -only_cells]]
	foreach b $a {
		
		set c [get_attribute [get_cells $b] is_integrated_clock_gating_cell]
			if {$c == "true"} {
				puts "$b is a clock gating cells with level $i"
			} 
	incr i
	} 

} 


# 1)  cells to be used in CTS 
	# Please do CTS check  
	# check_clock_trees
	
	#give alternative cells for cells already present in cts path 
	# go to scripts folder 	
	 	# cp /home/deepaksn/ORCA_TOP/PD/scripts/cts_include_refs.tcl .	
	 	# Edit file to use oly LVH and RVT cells 
	set_lib_cell_purpose -exclude cts [get_lib_cells]
	source ./scripts/cts_include_refs.tcl

# 2)  New Cells used to build clock tree 
set_lib_cell_purpose -include cts [get_lib_cells  "*/NBUFF*LVT */NBUFF*RVT */INVX*_LVT */INVX*_RVT */*DFF*"]

# 3)  NDR (Non default ruting rules) 
remove_routing_rules -all 
create_routing_rule iccrm_clock_double_spacing -default_reference_rule -multiplier_spacing 2 -taper_distance 0.4 -driver_taper_distance 0.4
set_clock_routing_rules -net_type sink -rules iccrm_clock_double_spacing -min_routing_layer M4 -max_routing_layer M5

# 4)  CTS constraints 
	# Max_clock_transition 
	current_mode func
	set_max_transition 0.15 -clock_path [get_clocks] -corners [all_corners]

	# target_skew 
	set_clock_tree_options -target_skew 0.05 -corners [get_corners ss_125c]
	set_clock_tree_options -target_skew 0.05 -corners [get_corners ss_m40c]
	set_clock_tree_options -target_skew 0.02 -corners [get_corners ff_m40c]
	set_clock_tree_options -target_skew 0.02 -corners [get_corners ff_125c]

	# target_latency 
	# Uncertainity 
	foreach_in_collection scen [all_scenarios] {
		current_scenario $scen
		set_clock_uncertainty 0.1 -setup [all_clocks]
		set_clock_uncertainty 0.05 -hold [all_clocks]
	}

	# USE CRPR
	set_app_options -name time.remove_clock_reconvergence_pessimism -value true

# 5) CTS exceptions 
	# man set_clock_balance_points 

	# Set select mux select lines as balancing points 	
	foreach_in_collection mode [all_modes] {
   		current_mode $mode
   		set_clock_balance_points \
      		-consider_for_balancing true \
      		-balance_points [get_pins "I_SDRAM_TOP/I_SDRAM_IF/sd_mux_*/S0"]
	}

	# Set dont constraints 
	set_dont_touch [get_cells "I_SDRAM_TOP/I_SDRAM_IF/sd_mux_*"]
	report_dont_touch I_SDRAM_TOP/I_SDRAM_IF/sd_mux_*

	set_dont_touch [get_cells "I_CLOCKING/sys_clk_in_reg"]
	report_dont_touch I_CLOCKING/sys_clk_in_reg

# 6) set cells to fix hold 
set_lib_cell_purpose -exclude hold [get_lib_cells] 
set_lib_cell_purpose -include hold [get_lib_cells "*/DELLN*_HVT */NBUFFX2_HVT */NBUFFX4_HVT */NBUFFX8_HVT"]

# 7) Give prefix to cells added in cts path 
set_app_option -name cts.common.user_instance_name_prefix -value clock_opt_clock_

# 7) Give prefix to cells added in data path  
set_app_option -name opt.common.user_instance_name_prefix -value clock_opt_opt_

#Build CTS 
# Remove route global 
remove_routes -global_route

# run clock opt 
clock_opt -to route_clock

save_block -as cts_done 

clock_opt -from final_opto
save_block -as clock_opt_done 

