# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load base sub-modules
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lcls-timing-core
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/axi-pcie-core/hardware/XilinxKcu1500
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lcls2-pgp-fw-lib/hardware/XilinxKcu1500

# Load common source code
loadRuckusTcl $::env(PROJ_DIR)/../../common/pcie

# Load local source Code
loadSource           -dir "$::DIR_PATH/hdl"

# Load the simulation testbed
loadSource -sim_only -dir "$::DIR_PATH/tb"
set_property top {ClinkKcu1500Pgp3Tb} [get_filesets sim_1]
