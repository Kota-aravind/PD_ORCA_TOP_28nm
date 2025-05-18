# pg_pattern  : Physical aspects . spacing pitch offset direction
# pg_stategy : for VDD and VSS  
# pg_strategy : for VDDH  
# Via rule 
# compile strategy and via rule : physical stuctures are created 

# Remove old pg rules and pg physical structures 
remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect

# Update VDD VDDH and VSS connections to cells 
connect_pg_net

# Create a via rule with dimension 8 x 10
set_pg_via_master_rule pgvia_8x10 -via_array_dimension {8 10}

set all_macros [get_flat_cells -filter "is_hard_macro"]

# save all macros belonging to PD_RISC_CORE power domain 
set hm(risc_core) [get_flat_cells -filter "is_hard_macro" I_RISC_CORE/*]

# save all macros belonging to PD_ORCA_TOP power domain 
set hm(top) [remove_from_collection $all_macros $hm(risc_core)]

##########Create pattern strategy via_rule for higher level straps (M7 M8) #################

# create pattern 
create_pg_mesh_pattern P_top_two \
 -layers { \
	{ {horizontal_layer: M7} {width: 1.104} {spacing: interleaving} {pitch: 13.376} {offset: 0.856} {trim : true} } \
	{ {vertical_layer: M8}   {width: 4.64 } {spacing: interleaving} {pitch: 19.456} {offset: 6.08}  {trim : true} } \
	} \
	-via_rule { {intersection: adjacent} {via_master : pgvia_8x10} }

# Strategy VDD VSS 
set_pg_strategy S_default_vddvss -core \
	-pattern   { \ 
		{name: P_top_two} {nets:{VSS VDD}} {offset_start: {0 0}} \
		} \
	 -blockage  { \
		{{nets: VDD} {voltage_areas: PD_RISC_CORE}} \
		} 
	-extension { \
		{{stop:design_boundary_and_generate_pin}} \
		}

# Strategy for VDDH inside PD_RISC_CORE 	 
set_pg_strategy S_va_vddh -voltage_areas PD_RISC_CORE \
	-pattern { \ 
		{name: P_top_two} {nets: {- VDDH}} {offset_start: {0 0}} \
		} \
		-extension { \
		{{direction:BL} {stop:design_boundary_and_generate_pin}} \
		} \

########################## Pattern strategy via_rule for lower level straps ##########################

# Create pattern 

create_pg_mesh_pattern P_m2_triple \
		-layers { \
			{ {vertical_layer: M2}  {track_alignment : track} {width: 0.44 0.192 0.192} {spacing: 2.724 3.456} {pitch: 9.728} {offset: 1.216} {trim : true} } \
			}\

# Create strategy for VDD VSS 

set_pg_strategy S_m2_vddvss -core \
	-pattern   { \
		{name: P_m2_triple} {nets: {VDD VSS VSS}} {offset_start: {0 0}} \
		} \
	-blockage  { \
		{{nets: VDD} {voltage_areas: PD_RISC_CORE}} {macros_with_keepout: $all_macros} \
		} \
	-extension {{stop:design_boundary_and_generate_pin }

# Create strategy for  VDDH 
set_pg_strategy S_m2_vddh -voltage_areas PD_RISC_CORE \
	-pattern  {\
		 {name: P_m2_triple} {nets: {VDDH - -}} {offset_start: {0 0}} \
		}\
	 -blockage  {\
	 	{macros_with_keepout: $hm(risc_core)} \
		}\
	 -extension { \
		{{direction:BL} {stop:design_boundary_and_generate_pin} }\
		}\

# Via rules has been mentioned to connect M2 to M7 
set_pg_strategy_via_rule S_via_m2_m7 \
	-via_rule { \
		{  \
		{{strategies: {S_m2_vddvss S_m2_vddh}}      {layers: { M2 }} {nets: {VDD VDDH}} }   \ 
		{{strategies: {S_default_vddvss S_va_vddh}} {layers: { M7 }} }  \
		{via_master: {default}} \ 
		} \
		{  \
		{{strategies: {S_m2_vddvss S_m2_vddh}}      {layers: { M2 }} {nets: {VSS}} } \  
		 {{strategies: {S_default_vddvss S_va_vddh}} {layers: { M7 }} } \
		{via_master: {default}} \
		} \
		} \
############################### Compile lower and higher level straps ############################
compile_pg -strategies {S_va_vddh S_m2_vddh}
compile_pg -strategies {S_default_vddvss S_m2_vddvss} -via_rule {S_via_m2_m7}

######################################################################################################
suppress_message PGR-599

################ Create pattern strategy via rules for macro rings ##############################

# Create macro ring patern 
create_pg_ring_pattern MACRO_RING_VDD_PATTERN -horizontal_layer M5 -horizontal_width 0.5 -vertical_layer M6 -vertical_width 0.5 

# Create macro ring stratgy for {VDD VSS}
set_pg_strategy MACRO_RING_VDD_STRAEGY -macros $hm(top)  -pattern {{name: MACRO_RING_VDD_PATTERN} {nets: {VDD VSS}} {offset: {0.3 0.3}} } 

# Create macro ring stratgy for {VDDH VSS}
set_pg_strategy MACRO_RING_VDDH_STRAEGY -macros $hm(risc_core) -pattern {{name: MACRO_RING_VDDH_PATTERN} {nets: {VDDH VSS}} {offset: {0.3 0.3}} }

# Via rule to connect M5 to M8 and M6 to M7 
set_pg_strategy_via_rule S_ring_vias -via_rule { \
	{{{strategies: {MACRO_RING_VDD_STRAEGY MACRO_RING_VDDH_STRAEGY}} {layers: {M5}}} {existing: {strap }}{via_master: {default}}} \
	{{{strategies: {MACRO_RING_VDD_STRAEGY MACRO_RING_VDDH_STRAEGY}} {layers: {M6}}} {existing: {strap }}{via_master: {default}}} \
}

############## Compile all macro ring strategy #################################################
compile_pg -strategies {MACRO_RING_VDD_STRAEGY MACRO_RING_VDDH_STRAEGY} -via_rule S_ring_vias



##################### Macro pin connection to rings ###############################

create_pg_macro_conn_pattern P_HM_pin -pin_conn_type scattered_pin -layers {M5 M6}
set_pg_strategy S_HM_top_pins -macros $hm(top) -pattern { {pattern: P_HM_pin} {nets: {VSS VDD}} }
set_pg_strategy S_HM_risc_pins -macros $hm(risc_core) -pattern { {pattern: P_HM_pin} {nets: {VSS VDDH}} }

compile_pg -strategies {S_HM_top_pins S_HM_risc_pins}

########################### Create pattern strategy via_rule for rails  ########################## 

create_pg_std_cell_conn_pattern P_std_cell_rail

set_pg_strategy S_std_cell_rail_VSS_VDD -core 
	-blockage  { {{nets: VDD} {voltage_areas: PD_RISC_CORE}} {macros_with_keepout: $all_macros} }
	 -pattern {{pattern: P_std_cell_rail}{nets: {VSS VDD}}} 
	-extension {{stop: outermost_ring}{direction: L  R  }}

set_pg_strategy S_std_cell_rail_VDDH -voltage_areas PD_RISC_CORE
	 -blockage  {macros_with_keepout: $all_macros} 
	-pattern {{pattern: P_std_cell_rail}{nets: {VDDH}}}

set_pg_strategy_via_rule S_via_stdcellrail -via_rule {{intersection: adjacent}{via_master: default}}

compile_pg -strategies {S_std_cell_rail_VSS_VDD S_std_cell_rail_VDDH} -via_rule {S_via_stdcellrail}

return

check_pg_missing_vias
check_pg_drc -ignore_std_cells
check_pg_connectivity -check_std_cell_pins none

