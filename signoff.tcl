cd PD_LAB 
mkdir STARRC 
cd STARRC
mkdir inputs scripts outputs 
cd outputs 
mkdir works spef 
cd works 
mkdir cbest cworst 
cd ../..

# Inputs required for spef extraction 
	# Netlist 
	# LEF 
	# routed  DEF (Routed block of ORCA_TOP.nlib) 
	# Nxtgrd file (Cmax and Cmin) 
	# Mapping 

cd inputs 
cp /home/deepaksn/ORCA_TOP/STARRC/inputs/saed32nm_1p9m_Cmax.nxtgrd .
cp /home/deepaksn/ORCA_TOP/STARRC/inputs/saed32nm_1p9m_Cmin.nxtgrd .
cp /home/deepaksn/ORCA_TOP/STARRC/inputs/saed32nm_tf_itf_tluplus.map .
cd ..

cd scripts 
cp /home/deepaksn/PD_LAB/PD/STARRC/scripts/* .

# Edit file paths 

cd ..
# come to STARRC 
csh
source /home/tools/synopsys/cshrc_synopsys
source ./scripts/best_spef.sh
source ./scripts/worst_spef.sh

#################################### Prime_time ############################################
# in PD_LAB folder 
mkdir PRIME_TIME 
cd PRIME_TIME/
mkdir inputs outputs scripts 

# Inputs required for prime time 
	# Routed netlist 
	# # DEF file of design for physical aware fixing 
	# .lib or .db 
	# SPEF 
	# SDC file 
	# UPF file 

# Open ICC2 and open route_opt_done block 
write_verilog ./../PRIME_TIME/inputs/routed_netlist.v

# Open ICC2 and open route_opt_done block 
write_sdc -output ./../PRIME_TIME/inputs/ORCA_TOP_func_ss_125c.sdc -scenario func.ss_125c
write_sdc -output ./../PRIME_TIME/inputs/ORCA_TOP_func_ff_m40c.sdc -scenario func.ff_m40c

# Copy UPF from 
# go to inputs of prime_time 
cp ./../../PD/inputs/ORCA_TOP.upf .

# go to inputs of prime_time 
cp ./../../STARRC/outputs/SPEF/ORCA_TOP.cworst.spef .
cp ./../../STARRC/outputs/SPEF/ORCA_TOP.cbest.spef .

# Go to scripts folder of prime_time folder 
cp /home/deepaksn/PD_LAB/PRIME_TIME/scripts/pt.tcl .
# edit paths in pt.tcl 

# open prime time 
# go to PRIME_TIME folder 
csh
source /home/tools/synopsys/cshrc_synopsys
pt_shell -output_log_file ./outputs/5_12_23.log

########################### Dumb reports #########################################################
report_constraint -all_violators -max_transition
report_constraint -all_violators -max_capacitance

################### Implement Finxing #######################################
set eco_alternative_area_ratio_threshold 0

set_eco_options -physical_icc2_lib ./../PD/outputs/works/ORCA_TOP.nlib -physical_icc2_blocks route_opt_done
create_voltage_area -region "{10.016 10.016} {423.912 180.56}" -power_domains PD_RISC_CORE -guard_band {{5.016 5.016}}

fix_eco_drc -type max_transition -buffer_list {NBUFFX2_HVT NBUFFX4_HVT NBUFFX8_HVT NBUFFX16_HVT NBUFFX32_HVT NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT NBUFFX32_RVT NBUFFX2_LVT NBUFFX4_LVT NBUFFX8_LVT NBUFFX16_LVT NBUFFX32_LVT} 

fix_eco_drc -type max_capacitance -buffer_list {NBUFFX2_HVT NBUFFX4_HVT NBUFFX8_HVT NBUFFX16_HVT NBUFFX32_HVT NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT NBUFFX32_RVT NBUFFX2_LVT NBUFFX4_LVT NBUFFX8_LVT NBUFFX16_LVT NBUFFX32_LVT}  


fix_eco_drc -type max_capacitance -buffer_list {NBUFFX2_HVT NBUFFX4_HVT NBUFFX8_HVT NBUFFX16_HVT NBUFFX32_HVT NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT NBUFFX32_RVT NBUFFX2_LVT NBUFFX4_LVT NBUFFX8_LVT NBUFFX16_LVT NBUFFX32_LVT}  -verbose -cell_type clock_network


# Few which cannot be fixed by tool , Fix by using scripts 


##### fix setup vioalation 
fix_eco_timing -type setup -methods {size_cell size_cell_side_load}

# Write changes to implement in ICC2 
write_changes -format icc2tcl -output ./outputs/icc2_changes.tcl

# go to ICC2 shell 
# source the ECO 
source ./../PRIME_TIME/outputs/icc2_changes.tcl
legalize_placement -incremental
route_eco -reuse_existing_global_route true -utilize_dangling_wires true -reroute modified_nets_first_then_others 

check_lvs 
check_routes 













