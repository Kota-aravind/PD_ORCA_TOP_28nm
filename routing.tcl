# check_routability 
# Enable few app options 
# Routing steps 
	# 1) Global routing 
	# 2) track assignment 
	# 3) detail routing 
	# 4) routing optimization  

# Enable time aware routing
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.detail.timing_driven -value true

# enable cross talk aware routing 
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true

# enalble for for timing check 
set_app_options -name  time.si_enable_analysis -value true 
set_app_options -name time.si_xtalk_composite_aggr_mode -value statistical
set_app_options -name time.all_clocks_propagated -value true

set_app_options -name opt.common.user_instance_name_prefix -value route_opt_

# read antenna rule file 
source /home/vlsiguru/PHYSICAL_DESIGN/TRAINER1/ICC2/ORCA_TOP/ref/tech/saed32nm_ant_1p9m.tcl

# Perform routing 
route_auto -save_after_global_route true -save_after_track_assignment true -save_after_detail_route true 

# do routing optimization 
route_opt 

# save_block 
save_block -as route_opt_done 

