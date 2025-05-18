open_block cts_done 
set_app_options -name ccd.hold_control_effort -value high
set_app_options -name clock_opt.hold.effort -value high
set_app_options -name opt.dft.clock_aware_scan_reorder -value true
clock_opt -from final_opto
save_block -as clock_opt_done_itr2

# report global timing 
report_global_timing 

# connect pg nets 
# Check max latency and global skew for all clocks
report_clock_qor -type latency -scenarios func.ss_125c -nosplit  > ./outputs/latency_func..ss_125c 
report_clock_qor -type latency -scenarios func.ss_m40c -nosplit  > ./outputs/latency_func..ss_m40c

# Report max_transition and max_capacitance violations 
report_clock_qor -type drc_violators > ./outputs/drc_violators_aco.txt


# Check pulse width 
report_min_pulse_width -all_violators

# logical/timing DRCs 
report_constraints -all_violators -max_capacitance
report_constraints -all_violators -max_transition 
