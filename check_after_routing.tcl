# checks on PG network
set_app_options -name route.common.net_max_layer_mode -value soft  
 remove_routing_blockages *
 create_routing_blockage -boundary {{5.0000 8.3440} {9.95 182.2320}} -net_types power -layers M1
  check_pg_drc
 check_pg_connectivity 
 
# Check LVS 
check_lvs -max_error 0 

# Check DRC 
check_routes


# Some basic short-cuts 
	# select shape  	
	# 1)Streching:  Extending or reducing length of shape 
	   	# press press s 

	# 2) Delete shape or via 
		# press d  
	
	# 3) Create a via for paticular metal 
		# shift + c 
	
	# 4) To cut any metal layers 
		# shift + l 
		# drag a line where u want to cut   
	
	# 5) To to manual routing 
		# shift + r  

# DRC violations 
	# Metal level DRC : ICC2 or Innovus 
		# 1) Shorts : when 2 diffent nets get connected 
		# 2) same_net_spacing
		# 3) diff_net_sapcing  
		# 4) Min width requirement 
		# 4) Min area requirement 
		# 5) Fat contact requirement 
		# 6) shorts : Routing restricted layers on macro 
	
	# Base level DRC : Base layers like poly , nwell , psub , diff , implant , contact cuts 	 		# PV tool (IC validator , Caliber) 
	# Signoff steps 
		# power/ir drop sign off : Redhawk 
		# Timing signoff  : Prime time tool  and start rc 
		# Physical verification : DRC 
					 # LVS 
					 # ERC 
					 # LEC  : Comparing 2 different netlist/RTL 

# Report timing with cross talk 
report_timing -crosstalk_delta -significant_digits 5 -input_pins -transition_time

# Fix max_transition 
report_constraints -all_violators -max_transition -scenarios func.ss_125c -nosplit > ./outputs/mtv_aro.txt 

# source upsize_driver.tcl script 
legalize_placement -incremental 
route_eco -reuse_existing_global_route true -utilize_dangling_wires true -reroute modified_nets_first_then_others

check_routes 
check_lvs -max_errors 0	

# Insert Buffer on routes 
set di [ get_attribute [get_nets net_sd_sys_read_data[15]] dr_length]
set hdi [expr $di / 2]
add_buffer_on_route -repeater_distance $hdi -lib_cell NBUFFX8_HVT [get_nets  net_sd_sys_read_data[15]] -punch_port -cell_prefix user_buffer_
legalize_placement -incremental
route_eco -reuse_existing_global_route true -utilize_dangling_wires true -reroute modified_nets_first_then_others

# To fix Automatically 
report_constraints -all_violators -max_capacitance -scenarios func.ss_125c -nosplit > ./outputs/mcv_aro.txt
source ./scripts/insert_buffer_on_routing.tcl
check_routes
check_lvs -max_errors 0 


	
