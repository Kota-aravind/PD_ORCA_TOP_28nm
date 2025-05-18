# Open the library 
open_lib ./outputs/works/ORCA_TOP.nlib/

# Open the block
open_block ORCA_TOP

# To get name of all cells in design  
get_flat_cells 

# To get no_of_cells in design 
sizeof_collection [get_flat_cells]

# Number of macros in design 
sizeof_collection [get_flat_cells -filter "is_hard_macro == true"]

# Number of std_cells excluding macros 
sizeof_collection [get_flat_cells -filter "is_hard_macro == false"]

# Creating die and core area

# Method - 1 ( Create core area using shape side_ratio and utilization ) 
# 1) Create core area and die area with uti = 0.75 , shape = R , side_ratio = {1 2}read_def /home/deepaksn/PD_LAB/PD/outputs/reports/fp/port_place.def , 
# core_offset = 5um 
# 2)  Create core area and die area with uti = 0.8 , Shape = L , side_ratio = {2 1 1 2} , core_offset =# 5um 
initialize_floorplan -core_utilization 0.8 -shape L -core_offset 5 -use_site_row -site_def unit -side_ratio {2 1 1 2} 

save_block -as core_area_with_sh_and_sr
close_blocks -force
close_lib 

# Method-2 (Create core area by utilization) 
# {{5 5} {900 5} {900 450} {450 450} {450 900} {5 900} {5 5}} 
 initialize_floorplan -boundary {{5 5} {900 5} {900 450} {450 450} {450 900} {5 900} {5 5}} -use_site_row -site_def unit -core_offset 5

save_block -as core_area_with_cor

# Method-3 (DEF Method)
# read_def file  
# Open_block ORCA_TOP . Where netlist is read 
# read_def 
read_def /home/deepaksn/PD_LAB/PD/outputs/reports/fp/port_place.def
save_block -as core_area_with_def


################################## ATTRIBUTES , CLASS and OBJECTS #######################
# Class , attributes , attribute_value 
# Class/Object : cells , pins , ports ,  pads , layers , site_rows  , core_area , design , via , net 
	# get_cell : It gives only cells in top module  	 
	# get_flat_cell : It give all cells in design 
	# get_flat_pins : All pins in design 
	# get_ports :  All ports in design 
	# get_layers : All layers in technology 

# Attributes : Foreach class we have many attributes
# Class: cell
	# Attributes : Height , width , area , Allowed_orientation , is_sequential , is_combinational , is_hard_macro

# Class : ports 
	# Attibutes :  length , Width , direction , layer 

# Class : layer 
	# Attributes : Min_width , min_spacing , max_width , pitch 
	
# To get allowed attributes 
list_attributes -application -class cell > ./outputs/reports/fp/cell_attr.txt

# For cell I_PCI_TOP/mult_x_32/U508 Find 
# Height
get_attribute [get_flat_cell I_PCI_TOP/mult_x_32/U508] height
# 1.672

# Width
 get_attribute [get_flat_cell I_PCI_TOP/mult_x_32/U508] width
 
# Area 
 get_attribute [get_flat_cell I_PCI_TOP/mult_x_32/U508] area

# ref_name : Lib_name : What_type_of_cell 
get_attribute [get_flat_cell I_PCI_TOP/mult_x_32/U508] ref_name

# Whether it is hard macro 
get_attribute [get_flat_cell I_PCI_TOP/mult_x_32/U508] is_hard_macro

# Whether it sequential cell
get_attribute [get_flat_cell I_PCI_TOP/mult_x_32/U508] is_sequential

# Whether it is combo cell 
get_attribute [get_flat_cell I_PCI_TOP/mult_x_32/U508] is_combinational

# For M1 metal layer find 

# pitch 
get_attribute [get_layer M1] pitch

# min_width
set a [get_attribute [get_layer M1] min_width]

#  min_spacing 
set a [get_attribute [get_layer M1] min_spacing]

#  routing_direction  
get_attribute [get_layer M1] routing_direction

# Get all co-ordinates of core_area 
get_attribute [get_core_area] boundary

# Filter the objects

# Get cells only macros 
get_flat_cells -filter "is_hard_macro == true"
sizeof_collection [get_flat_cells -filter "is_hard_macro == true"]

# get cells only sequential cells
get_flat_cells -filter "is_sequential == true" 
sizeof_collection [get_flat_cells -filter "is_sequential == true"]

# get_cells height 2*site_row_height  
# 2 * 1.672 = 
set dh [expr 2 * 1.672]
get_flat_cells -filter "height == 3.344"
sizeof_collection [get_flat_cells -filter "height == 3.344"]

# get cells ref_name  AND2X1_HVT 
get_flat_cells -filter "ref_name == AND2X1_HVT"
sizeof_collection [get_flat_cells -filter "ref_name == AND2X1_HVT"]

# get the cells which having pin_count more than 5 
get_flat_cells -filter "number_of_pins > 5"
sizeof_collection [get_flat_cells -filter "number_of_pins > 5"]

# get the count/name of all the sequential cells except macros
sizeof_collection [get_flat_cells -filter "is_sequential == true && is_hard_macro == false "]

################## GUI OPERATION ###############################
# In GUI Observe Site rows 
# In GUI Observe Site izeolomns 
# In GUI observe Tracks 
# Compare track distance with metal layer attribute(Pitch) 


################################### TCL Programs ####################################### 
# Write a TCL program to find Utilization of core area by Formula method 
	# In script folder , create a file uti_tcl_program .  
# Write a TCL program to print Min_spcaing  pitch and min_width for all routing metal layers 
	# M1 M2 M3 M4 M5 M6 M7 M8 M9 MRDL 
# Write TCL to find % of HVT cells , % of RVT cells , % of LVT cells.
#
# ################## Port_placement #################################################### 
#   
# Ports : Input and output of a block is called as ports .  
# Ports are Metal layers 
# Generally Higher metal layers are used for ports placements:  
# M1 - M9 : M9 is reserver for full_chip level 
# M7 - M8 We use for power planning :USed to Create Straps 
# M5 and M6 is used port placement  
# Ports should be on metal tracks
# input_ports : 95 
# output_ports : 142 
# Total ports : 237 

# To get all ports in design 
sizeof_collection [get_ports]

# get all input ports 
sizeof_collection [get_ports -filter "direction == in"]
sizeof_collection [all_inputs ]

# get all output ports 
sizeof_collection [get_ports -filter "direction == out"]
sizeof_collection [all_outputs ]

# to get all clock ports 
get_ports *clk*

# How to get input ports except clock ports  
sizeof_collection [remove_from_collection [all_inputs] [get_ports *clk*]]

######################## PORT PLACEMENT #########################################
# i) Place all input ports except clock ports  at blockage 1 location 
# Layer : M6 , Min_spacing - 1 track 
set a [get_attribute [get_placement_blockages pb_0] bbox ]
create_pin_guide -boundary $a -layers {M5 M6} -pin_spacing 1 [remove_from_collection [all_inputs] [get_ports *clk*]]
place_pins -ports [remove_from_collection [all_inputs] [get_ports *clk*]]

# # ii) Place all clock ports  at blockage 2 location 
# Layer : M5 , Min_spacing - 5 track 
 set a [get_attribute [get_placement_blockages PB_2] bbox ]
create_pin_guide -boundary $a -layers M5 -pin_spacing 5 [get_ports *clk*]
place_pins -ports [get_ports *clk*]

# # ii) Place all output ports  at blockage 3 location 
# Layer : M5 , Min_spacing - 1 track 
set a [get_attribute [get_placement_blockages PB_1] bbox ]
create_pin_guide -boundary $a -layers M5 -pin_spacing 1 [all_outputs]
place_pins -ports [all_outputs ]

# Check after port placement 
	 check_pin_placement -ports [get_ports] -wire_track true

############################# Voltage area creation ######################################################### 
# UPF : Unified Power Format 
# UPF is required when design power gating or Multi-voltage design 
# Power_domains : 
	# a) PD_ORCA_TOP : All cells 
	# b) PD_RISC_CORE :  I_RISC_CORE family
	
# Refer to va_bound.tcl
################################### Verification after creating voltage area ############################# 
# 1) Validate Utilization 
#  0.73 < uti < 0.8 
# Find Utilization of voltage area 
#  uti = ( total cell area belonging PD_RISC_CORE) / Voltage area 

# Voltage area 
set va [get_attribute [get_placement_blockages pb_1] area]

# Find area cells belonging to PD_RISC_CORE voltage
set tca 0
foreach_in_collection c [get_flat_cells -filter "power_domain == PD_RISC_CORE"] { 
	set ca [get_attr [get_cells $c] area]
	set tca [expr $ca + $tca] 
	} 
puts "total_cell_area_of_pd_rics_core is : $tca"

# Find Utilization 
set uti [expr ($tca / $va) * 100]
puts $uti 

# 2)  Voltage should be on site rows and site coloums . 
# Get gaurd_band co-ordinates 
set g_co [get_attribute [get_voltage_areas PD_RISC_CORE ] bbox]

# get voltage area co_ordinates 
set llx [expr [lindex $g_co 0 0] + 5.016] 
set lly [expr [lindex $g_co 0 1] + 5.016]
set urx [expr [lindex $g_co 1 0] - 5.016]
set ury [expr [lindex $g_co 1 1] - 5.016]

# Find Width (urx - llx)  and height (ury - llY ) 
set w [expr $urx - $llx]
set h [expr $ury - $lly]

# Find Whether height and width is integral multiple of site rows 
set hv [expr $h / 1.672]
	lassign [split $hv .] h_inte h_dec 

set wv [expr $w / 0.152]
	lassign [split $hv .] w_inte w_dec 

if {($h_dec == 0) && ($w_dec == 0) } {
	puts "Voltage area is validated for h and w : Both are on site rows" 
} else {
	puts "Voltage area is not validated for h and w : They are not on site rows" 
}
# connect_pg_net
	# Logically connect VDD , VDDH and Vss to std_cell pins and macro pins are updated 
	connect_pg_net 

# 3) Check mv design 
 check_mv_design
	 # It will verify UPF constraints 
	 	# Power domain rule 	
	 	# Whether power domains has primary power and ground voltage 
	 	# Whether power domains has voltage area or not
	 	# Whether Whether level shifters are inserted or not 
	 	# Whether level shifer rules are proper or not 
 
######################################## Macro Placement ###################################### 
# Macro placement guidelines 
	#   i) Place maocros based on hirearchies  
	#   ii) Place macros at core edges 
	#   iii) Place macros based on fly line analysis 
		# Do fly line analysis between macro to macro 
		# Do fly line analysis between macro to port 
	# iv) Do macro placement so that it is not blocking ports 
	# v) Donts stack macros 
	# vi) Mantain min spacing between macros 
		# sp = (no_of_ports * pitch)  /   (horizontal or vertical layers ) 
	# vii) Apply keepout marging aroung macros , To protect macro pins 
	# viii) Apply soft blockage / partial blockage in macro channel 

# Commands for manually macro placement 
	# data_flow_fly_lines : We used to decide macro connection to the port 
	# net_connection : We used to place macros 

# Align and distribute 
	# Align  : It is used to give distance between core area and macros
		# From core area to macro : 10u 

	# Distribute : It is used to give distance between macro and macro 
		# Between macro to macro to : 15u  
	
	# Unfix Macros 
	set_fixed_objects [get_flat_cells -filter "is_hard_macro"] -unfix	

	# Fix macros 
	set_fixed_objects [get_flat_cells -filter "is_hard_macro"]
	
	# Remove all placement blockages
	remove_placement_blockages -all 	

	# To apply soft blockage automatically in macro channel 
	derive_placment_blockage 

	# Apply partial in macro channel manually 
	#
	# Command to apply partial blockage
create_placement_blockage -boundary {{70.6450 505.4250} {85.6450 889.5200}} -type partial -blocked_percentage 65
	
	# Around macros apply keepout margin 
	create_keepout_margin -type hard -outer {1 1 1 1} [get_flat_cells -filter "is_hard_macro"]

	# Commands to check percentage of congestion
	set_app_options -name place.coarse.continue_on_missing_scandef -value true
	set_ignored_layers -max_routing_layer M6 -min_routing_layer M2
	create_placement
	legalize_placement
	report_congestion -rerun_global_router
	reset_placement 

################################ Physical only cell placement ###################################
# Physical cell Placement 
	# Filler cells 
		# Why : To maintain nwell or sustrate continuity 
		# Where : Where there is a gap in site rows 
		# When : After timing signoff (After routing stage) 

	# Endcap cells
		# Why : Due to well proximity effect , Cells at edges of nwell may get affected 
			# With performance . So we place endcap cells at end of site rows 
		# Where : Where nwell is going to end 
			# Left and right side of core area 
			# Left and right side of macros 
			# At Left and right side of voltage area 
		# When : Before placement stage (After macro placement)  

	#  tap cells 
		# Why : Tap cells provide tap connections (Connecting VDD to nwell and Psub to VSS) 
			# To address latchup problem .   
FFX2LVT  design   not_repaired  record_unbound_instance                   missing_logical_reference_10_CLKBUFFX2LVT
		# Where : Placed in site rows after every few micro meters specfified by design rule 				# file checker board fashion  
		# When : Before placement stage (After macro placement) 

	#  Tie cells
		# Why : To Connect gate of cell to constant Logic zero / Logic one 
		# Where : Place near to cells which want tie cell connection 
		# When : Placed During placement staged

	# Decap cells
		# Why : To boost VDD when there is drop in voltage 
		# Where : Feedback from Redhawk team 
		# When : After routing stage (Power signoff ) 

	# Spare cells 
FFX2LVT  design   not_repaired  record_unbound_instance                   missing_logical_reference_10_CLKBUFFX2LVT
		# Why : To perform Functional ECO 
		# Where : Every few regions 
		# When :  CTS 

# Place end cap cells . 
	get_lib_cells *DCAP*
	# to remove endcap cells 
	remove_cells [get_flat_cells -all *boundary* ]
	# to create end cap cells 
	set_boundary_cell_rules -left_boundary_cell DCAP_HVT -right_boundary_cell DCAP_HVT -at_va_boundary
	compile_boundary_cells
	check_boundary_cells

# Place tap cells 
	# to remove tap cells 
	remove_cells [get_flat_cells -all *tapfiller*] 	
	# to create tap cells 
	create_tap_cells -lib_cell DCAP_HVT -distance 30 -skip_fixed_cells -pattern stagger
	check_legality	

	save_block -as physical_cells_placed

####################################### Power Planning ###############################################
source ./scripts/powerfinal.tcl

# Check pg connectivity 
check_pg_connectivity -check_std_cell_pins none

# Problem 1 : Macro rings broken , Because of  M2 and M7 strap connectivity at macro ring region . 
	# Solution 
		#  Increase keepout margin so that ring will form inside keepout margin . 
		#  M2 is not routed inside  keepout margin of macros 
		#  M2 connecting to M7 will not be a problem for macro rings . 
	# steps : 
		# remove all keepout margins  	
		remove_keepout_margins * 

		# apply keepout margin with 2um 
		create_keepout_margin -outer {2 2 2 2} -type hard [get_flat_cells -filter "is_hard_macro"]      
		
		# source powerfinal.tcl 
		# check pg connectivity

# Problem 2 : At top edge of voltage area, VDD is formed , but for cells present in voltage area  VDDH is connected . 
		# As VDD and VDDH are separate nets there is broken VDD and VDDH formed as rails  
	# Solution : 
		#   Increase/Decrease voltage area by one site row 
		#   So that VSS is formed at top edge of voltage area . VSS is same in both voltage area no issues 
	# Steps 
		# First remove boundary cells and tap cell
			remove_cells [get_flat_cells -all *boundary* ]
			remove_cells [get_flat_cells -all *tapfiller*]

		# Decrease voltage area on top by one site row 
			edit va_bound.tcl 
			source ./scripts/va_bound.tcl 
 	
		# Add boundary and tap cells again 
		set_boundary_cell_rules -left_boundary_cell DCAP_HVT -right_boundary_cell DCAP_HVT -at_va_boundary
		compile_boundary_cells 

		create_tap_cells -lib_cell DCAP_HVT -distance 30 -skip_fixed_cells -pattern stagger

		# source powerfinal.tcl
		source  ./scripts/powerfinal.tcl 

		# check_pg_connectivity 
		check_pg_connectivity -check_std_cell_pins none

# TO remove floating VDD rails formed in guard band region 
# Create routing blockage at co-ordinates : {5.0000 8.3440} {10.0160 182.2320}
remove_routing_blockages *
create_routing_blockage -layers M1 -net_types power -boundary {{{5.0000 8.3440} {9.9 182.2320}}}

# Problem 3 : For one macro,  VSS macro rings are not connecting to VSS straps 
FFX2LVT  design   not_repaired  record_unbound_instance                   missing_logical_reference_10_CLKBUFFX2LVT
	# At the location where horizontal strap (m7) should connect to M6 macro ring , Vias are formed connecting 
	# M7 to M8 
	# At the location where vertical strap (m8) should connect to M5 ring , M7 horizontal VDD strap is running 
	
	# Solution : 
		# Move macro to right 0.6 um and top 2.25 um 

	# steps :
		 # First remove boundary cells and tap cell
			remove_cells [get_flat_cells -all *boundary* ]
			remove_cells [get_flat_cells -all *tapfiller*]

		# Unfix macros 
			set_fixed_objects -unfix [get_flat_cells -filter "is_hard_macro"]

		# Move macro up and right 
			# to move 2.25 to top , go to  align mode , select anchor as parent , spacing  7.75 , 
			# select align from top 
			# to move 0.6um to right , go to distribute mode , select anchor as selection , spacing as 
			# 15.6 , select 2 macros and select distribute from left 

		# source power plan once again 
			source ./scripts/powerfinal.tcl

		# check pg connectivity . 
				check_pg_connectivity -check_std_cell_pins none

# After fixing all violation 
# Add all tap cells and boundary cells 
set_boundary_cell_rules -left_boundary_cell DCAP_HVT -right_boundary_cell DCAP_HVT -at_va_boundary
compile_boundary_cells 

create_tap_cells -lib_cell DCAP_HVT -distance 30 -skip_fixed_cells -pattern stagger
# Fix macros 
set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

# source blockage script 
source ./scripts/chandra.tcl
# remove top and bottom blockage inside volatge area 

# source powerplan script again 
source ./scripts/powerfinal.tcl

# check pg connectivity .
check_pg_connectivity -check_std_cell_pins none

source ./scripts/powerfinal.tcl

# connect_pg_nets 

# check_pg_drc 
save_block


################################################# Sanity Checks ###########################
# Do before creating core area and die area 
# 1) Check Design Mismatch : Checks consitency of ndm files . 
		# For all cells in netlist we should have .lib and .lef 
	report_design_mismatch 

#  2) Check Netlist : It checks consitency of netlist 
#  	a) No floating ports 
#  	b) No floating pins in cell 
#  	c) no multdriven nets/input pins 
#  	d) no assign keywords
 	check_netlist > ./outputs/chk_netlist.txt  	

 # 3) Check_timing : Verifies timing constraints of design  
 source ./inputs/sdc_constraints/mcmm_ORCA_TOP.tcl
 check_timing -modes func > ./outputs/chk_timing_func.txt
check_timing -modes test > ./outputs/chk_timing_test.txt

# 4) Check MV Design 
	# It checks Multivoltage design constraints 
	# It checks consistancy of power domains 
		# Whether power domains has cells or not 
		# Primay voltage in power domain is proper or not 
		# It checks level shifter rulers and all level shifters are inserted or not 
		# It checks power switches , isolation cells , retention cells rules and whether 
				# They are inserted are not 
		# Whether voltage area is there for every power domain or not  
check_mv_design

# 5) Check scan chain 
	# It checks consistency of scandef file 
	read_def ./inputs/ORCA_TOP.scandef
	 check_scan_chain

