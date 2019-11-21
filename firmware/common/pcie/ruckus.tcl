# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local source Code 
loadSource  -lib cameralink_gateway     -dir "$::DIR_PATH/rtl"
loadConstraints -dir "$::DIR_PATH/xdc"
