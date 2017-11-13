# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load submodules' code and constraints
loadRuckusTcl $::env(TOP_DIR)/submodules/surf

# Load target's source code and constraints
#loadSource -sim_only -dir "$::DIR_PATH/tb/"

# Set the top level synth_1 and sim_1
set_property top {ClinkTb} [get_filesets sim_1]

