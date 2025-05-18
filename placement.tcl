##################### Placement #####################################################
# Checks Before placement
	# All_basic sanity checks
		#  Check timing , check design mismatch , check scan def , check netlist , check mv design 
	#  Port placement 
		# Whether all ports are placed 
		# No overlap of ports 
		# Sufficient spacing between ports 
		# ports are on routing tracks 
	# Macro placements 
		# all macro guidlines are followed 
		# Macro are fixed    
	# Physical cells are placed or not 
		# check_legality 
		# Utilization check 
	# Power planning 
		# pg connectivity check
		# Missing vias /unconnected vias 
 

# Copy block 
copy_block -from_block sanity_checks -to_block placement
open_block placement

# Do pre-placement check 
check_design -checks pre_placement_stage

# Macros has to be fixed 
set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

# What if there is no scandef 
	# Without scandef coarse placement will not run 
		# To run coarse placement without scandef use this app option 
		set_app_options -name place.coarse.continue_on_missing_scandef -value true
		# No scan chain reordering is done (No DFT optimization is done) 

	# We have scandef , Pls load it 
	read_def ./inputs/ORCA_TOP.scandef
	# (DFT optimization is done (scan chain reordering))  

# Tie cell insertion 
	# Tie cells has attributes dont_touch and dont_use 
	# Remove dont_touch and dont_use attributes on tie cells 
	get_lib_cells *TIE*
	set_attribute [get_lib_cells *TIE*] dont_touch false
	set_attribute [get_lib_cells *TIE*] dont_use false

# Enable advance legalizer 
	# Advance legalizer can do search and repair
	# It helps fixing timing and congestion 
	set_app_options -name place.legalize.enable_advanced_legalizer -value true
	set_app_options -name place.legalize.legalizer_search_and_repair -value true 

# set local cell density
	set_app_options -name place.coarse.max_density -value 0.75

# Set fanout limit
	set_app_options -name opt.common.max_fanout -value 25	

# Make clock path ideal 
	set_ideal_network [all_fanout -clock_tree ]

# Set allowed routing layers 
	# We are using only layers from M2 to M6 
		# Obove M6 is power planning is done 
		# Below M2  , We have standard cells 
		set_ignored_layers -max_routing_layer M6 -min_routing_layer M2 
		set_app_options -name route.common.net_max_layer_mode -value hard 
		set_app_options -name route.common.net_min_layer_mode -value allow_pin_connection

# Create coarse (rough) placement
	create_placement 

# Legalize placement 
	legalize_placement

	save_block

# Check Congestion 
	report_congestion -rerun_global_router
	# Global routing : Estimation of real routing 
	# Always finds shortest path 
	# Overflow = required tracks - available tracks 
			# 5 - 4 = 1
			# 5 - 10 = -5 
		# How to reduce congestion 
			# 1) Run congestion driven placement 
				create_placement -congestion_effort high  
			# 2) Run refine_placement command : It runs incremental placement to reduce congestion 
			 	refine_placement 
			# 3) If Congestion is in macro channel :  Apply soft/partial blockage 
			# 4) If congestion is in core area because of cell density / Pin density 
					# Apply keepout margin and spread cells 
					# select cells where u have more cell density or pin density 
					change_selection [get_flat_cells [get_selection ] -filter "number_of_pins > 5" ]
					 create_keepout_margin -outer {2.128 0 2.128 0} [get_selection ]
					legalize_placement -incremental

					# Apply partial blockage and spread cells 
			# 5) Congestion because of complex cells at particular region
					# Apply keepout margin and spread cells 
			# 6) Change floorplan 
	 
# Place_opt 
	# initial_placement : Coarse placement 
	# initial_drc :
		#  Timing DRC (fix Max_cap and max_trans violation) and  
		#  High_fanout net synthesis : Spilt fanout by inserting buffers 
	# Datapath optimization : reduce delay in datapath to reduce setup violation 
	# Final  placement 
	# Final Data path optimization (Final optimation) : Fixing setup violation
place_opt -from initial_drc
save_block -as place_opt_done_itr3

# how many cell added or removed from design
 open_block power_plan_completed
eco_netlist -by_block place_opt_cmplte -write_changes ./outputs/eco_netlist.tcl 

# Report Number of cells added or removed from design 
	# Tool removed : 3701 
	# Cells added : 5337
	# Number of extra cells added : 5337 - 3701 = 1636 (func_cell + tie cells) 

# Reports Overall Utilization (78.55 %) 
	create_utilization_configuration -include all user_uti 
	report_utilization -config user_uti

# Report Utilization for voltage area
	# Apply blockage on voltage area (pb_0)
	set a [get_attribute [get_placement_blockages pb_0] bbox]  
	report_utilization -config user_uti -region $a

# Report Design 
	# Report design will give cell count 
	report_design

# Congestion 
	report_congestion -rerun_global_router
 
# Max_trans and max_cap violations
	# Do global routing  
	route_global
	# max_trans_violation (Slack)  = Required transition - Actual transition   
report_constraints -all_violators -max_transition -significant_digits 3 -nosplit -scenarios func.ss_m40c  > ./outputs/mtv_apo.txt

# Fixing
	# 0) Change floor plan 
		# Go to Coarse placement block (block_name : Placement)  
		# Change partial blockage percentage of I_SDRAM_MACROS to 70% 
		# reset_placement 
		# run place_opt 
		# save_block -as place_opt_done_2 

	# 0.1) Change floor plan 
		# open_block sanity_check_done 
		# reset_placement
		# remove_routes -global_route 
		# remove boundary and tap cells 
		  remove_cells [get_flat_cells -all *boundary* ]
		  remove_cells [get_flat_cells -all *tapfiller*]
		# Unfix macros 
		  	set_fixed_objects -unfix [get_flat_cells -filter "is_hard_macro"]
		# Change macro location and align it 
		# source power planning fix it 
		# Add tap cells and boundary cells
		set_boundary_cell_rules -left_boundary_cell DCAP_HVT -right_boundary_cell DCAP_HVT -at_va_boundary
		compile_boundary_cells 

		create_tap_cells -lib_cell DCAP_HVT -distance 30 -skip_fixed_cells -pattern stagger

		# Fix macros 
		set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

		# source blockage script 
		source ./scripts/chandra.tcl
		# remove top and bottom blockage inside volatge area 
		source ./inputs/sdc_constraints/mcmm_ORCA_TOP.tcl

		# source mcmm file and scandef 
		 read_def ./inputs/ORCA_TOP.scandef

		# Source placement constraints 
		# do placeopt and save 
		place_opt 
		save_block -as place_opt_done_itr3



	# 1) Upsize Driver / Vt swap driver 
		# Fails in two situations 
			# 1) If Driver is already at highest drive strength 
			# 2) If driver is a macro

		# From violated net find driver 
set dn [get_flat_cells -of_objects  [get_pins  [all_connected I_BLENDER_0/N331 -leaf ] -filter "direction == out"]] 

		# Find ref_name of driver 
		set rdn [get_attribute [get_flat_cells $dn] ref_name]

		# Upsize the driver 
		size_cell $dn AOI222X2_RVT
	# Automated scripts for upsizing 
	# upsize_diver.tcl

	# 2) Insert Buffer Near driver Pin and Upsize buffer to fix violation 
	set pi  [get_pins [all_connected I_PCI_TOP/net_pci_write_data[31] -leaf] -filter "direction == out"]
	insert_buffer $pi NBUFFX8_HVT
	legalize_placement -incremental 

	# Automated script for inserting buffer 
	# Automated script for inserting buffer : insert_buffer.tcl 
		
# Printing max_capacitance violation for all scenarios 
	foreach_in_collection a [get_scenarios ] {                                                  
		puts "scenario : [get_object_name $a] "                                                                 
		report_constraints -all_violators -max_capacitance -scenarios $a                                        
	} > ./outputs/mcv_for_all_scenarios.txt


# source mcmm file again 
	source ./inputs/sdc_constraints/mcmm_ORCA_TOP.tcl

# Set multicycle path
	# Fast to slow clock  	
	current_mode func 
	set_multicycle_path -start 2 -setup -from [get_clock SYS_2x_CLK] -to [get_clock SYS_CLK]
	set_multicycle_path -start 1 -hold -from [get_clock SYS_2x_CLK] -to [get_clock SYS_CLK]

	current_mode test
	set_multicycle_path -start 2 -setup -from [get_clock SYS_2x_CLK] -to [get_clock SYS_CLK]
	set_multicycle_path -start 1 -hold -from [get_clock SYS_2x_CLK] -to [get_clock SYS_CLK]

	# Slow to fast clock 
	current_mode func 
	set_multicycle_path -end 2 -setup -from [get_clock SYS_CLK] -to [get_clock SYS_2x_CLK]
	set_multicycle_path -end 1 -hold -from [get_clock SYS_CLK] -to [get_clock SYS_2x_CLK]

	current_mode test
	set_multicycle_path -end 2 -setup -from [get_clock SYS_CLK] -to [get_clock SYS_2x_CLK]
	set_multicycle_path -end 1 -hold -from [get_clock SYS_CLK] -to [get_clock SYS_2x_CLK]

# Setup fixing 
	report_global_timing 	
	# 1) Vt swapping
	# 2) Upsize driver 
	# 3) split fanout by inserting buffer 
	# 4) logical reordering 

report_timing -transition_time -nosplit -significant_digits 3 -max_paths 42 > ./outputs/sv_apo.txt
# Designer 	
	# a) Vt swpping
	# Bottle neck cell  
	size_cell I_SDRAM_TOP/I_SDRAM_IF/U16802 AO22X1_LVT

	# b) Upsize driver (If more transition time ) 
	# c) Path grouping . Assign weightage to intersted paths 
	group_path -from [get_flat_cells -filter "is_sequential" I_BLENDER*] -to [get_flat_cells -filter "is_sequential" I_BLENDER*] -weight 4 -name BLENDER_FAMILY
	set_app_options -name opt.common.enable_rde -value true
	place_opt -from final_place
	save_block -as place_opt_done_with_grouping
 
