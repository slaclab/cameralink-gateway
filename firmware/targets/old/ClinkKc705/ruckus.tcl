# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load submodules' code and constraints
loadRuckusTcl $::env(TOP_DIR)/submodules/surf

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl/"
loadConstraints -dir "$::DIR_PATH/hdl/"

# Load ila core for debugging
loadIpCore -path "$::DIR_PATH/coregen/ila_0.xci"
