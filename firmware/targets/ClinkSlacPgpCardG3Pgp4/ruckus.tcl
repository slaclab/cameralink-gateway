# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2020.2 of Vivado (or later)
if { [VersionCheck 2020.2] < 0 } {exit -1}

# Load base sub-modules
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lcls-timing-core
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/axi-pcie-core/hardware/SlacPgpCardG3

# Load the lcls2-pgp-fw-lib source code
loadSource -lib lcls2_pgp_fw_lib -path "$::env(PROJ_DIR)/../../submodules/lcls2-pgp-fw-lib/shared/rtl/PgpLaneRx.vhd"
loadSource -lib lcls2_pgp_fw_lib -path "$::env(PROJ_DIR)/../../submodules/lcls2-pgp-fw-lib/shared/rtl/PgpLaneTx.vhd"
loadSource -lib lcls2_pgp_fw_lib -path "$::env(PROJ_DIR)/../../submodules/lcls2-pgp-fw-lib/shared/rtl/TimingPhyMonitor.vhd"

# Load the l2si-core source code
loadSource -lib l2si_core -dir "$::env(PROJ_DIR)/../../submodules/l2si-core/xpm/rtl"
loadSource -lib l2si_core -dir "$::env(PROJ_DIR)/../../submodules/l2si-core/base/rtl"

# Load common source code
loadRuckusTcl $::env(PROJ_DIR)/../../common

# Load local source Code
loadSource      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/hdl"

# Updating impl_1 strategy
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# Use an existing .DCP from previous routed.dcp file that's known to meet timing as the starting point
set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs impl_1]
import_files -fileset utils_1 "$::DIR_PATH/dcp/ClinkSlacPgpCardG3Pgp4_incremental_compile.dcp"
set_property incremental_checkpoint [get_files {ClinkSlacPgpCardG3Pgp4_incremental_compile.dcp}] [get_runs impl_1]
