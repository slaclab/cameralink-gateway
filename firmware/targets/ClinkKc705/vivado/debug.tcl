##############################################################################
## This file is part of 'RCE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'RCE Development Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################
set RUCKUS_DIR $::env(RUCKUS_DIR)
set IMAGENAME  $::env(IMAGENAME)
source -quiet ${RUCKUS_DIR}/vivado_env_var.tcl
source -quiet ${RUCKUS_DIR}/vivado_proc.tcl

## Open the run
open_run synth_1

# Get a list of nets
set netFile ${PROJ_DIR}/net_log.txt
set fd [open ${netFile} "w"]
set nl ""
append nl [get_nets {U_App/U_Core/LayerGen[2].U_Layer/*}]

regsub -all -line { } $nl "\n" nl
puts $fd $nl
close $fd

## Setup configurations
set ilaName u_ila_0

## Create the core
CreateDebugCore ${ilaName}

## Set the record depth
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]

## Set the clock for the Core
SetDebugCoreClk ${ilaName} {U_App/U_Core/cnnClk}

ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/confData[0][*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dspData[*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dspIdx[done]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dspIdx[index][*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dspIdx[last]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dspIdx[valid]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dstIdx[bias]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dstIdx[done]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dstIdx[last]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/dstIdx[valid]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/idx_index[*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/inMaster[data][*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/inMaster[valid]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/inSlave[idx][done]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/inSlave[idx][index][*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/inSlave[idx][valid]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/memData[49][*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/srcIdx[bias]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/srcIdx[channel]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/srcIdx[config][*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/srcIdx[done]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/srcIdx[index][*]}
ConfigProbe ${ilaName} {U_App/U_Core/LayerGen[2].U_Layer/srcIdx[last]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${IMAGENAME}.ltx

