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
append nl [get_nets {U_ClinkTop/U_Framer0/*}]
append nl [get_nets {U_ClinkTop/*}]
append nl [get_nets {*}]

regsub -all -line { } $nl "\n" nl
puts $fd $nl
close $fd

## Setup configurations
set ilaName u_ila_0

## Create the core
CreateDebugCore ${ilaName}

## Set the record depth
set_property C_DATA_DEPTH 1024        [get_debug_cores ${ilaName}]
#set_property C_EN_STRG_QUAL 1        [get_debug_cores ${ilaName}]
#set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores ${ilaName}]

## Set the clock for the Core
SetDebugCoreClk ${ilaName} {U_ClinkTop/U_Framer0/sysClk}

ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/parValid[0]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/parValid[1]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/parValid[2]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/parData[0][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/parData[1][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/parData[2][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/parReady}

ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][0][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][1][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][2][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][3][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][4][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][5][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][6][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][7][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][8][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][data][9][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][dv]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][fv]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][lv]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[portData][valid]}

ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][0][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][1][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][2][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][3][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][4][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][5][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][6][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][7][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][8][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][data][9][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][dv]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][fv]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][lv]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[byteData][valid]}

ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[master][tData][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[master][tKeep][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[master][tLast]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[master][tValid]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[inFrame]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[dump]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/r[bytes][*]}

ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/packMaster[tData][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/packMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/packMaster[tLast]}
ConfigProbe ${ilaName} {U_ClinkTop/U_Framer0/packMaster[tValid]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
#write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${IMAGENAME}.ltx

