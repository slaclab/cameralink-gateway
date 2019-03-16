# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load base sub-modules
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lcls-timing-core
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/axi-pcie-core/hardware/XilinxKcu1500
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lcls2-pgp-fw-lib/hardware/XilinxKcu1500

# Load only MIG[3] source code (located in SSI1)
set DdrPath $::env(PROJ_DIR)/../../submodules/axi-pcie-core/hardware/XilinxKcu1500/ddr
loadSource      -path "${DdrPath}/rtl/MigPkg.vhd"
loadSource      -path "${DdrPath}/rtl/Mig3.vhd"
# loadIpCore      -path "${DdrPath}/ip/XilinxKcu1500Mig3Core.xci"
# loadConstraints -path "${DdrPath}/xdc/XilinxKcu1500Mig3.xdc"

# Load common source code
loadRuckusTcl $::env(PROJ_DIR)/../../common/pcie

# Load local source Code
loadSource           -dir "$::DIR_PATH/hdl"
loadSource -sim_only -dir "$::DIR_PATH/tb"

set_property top {ClinkKcu1500Pgp2bTb} [get_filesets sim_1]
