##############################################################################
## This file is part of 'Camera link gateway'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'Camera link gateway', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

##############################
# Get variables and procedures
##############################
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Bypass the debug chipscope generation
return

############################
## Open the synthesis design
############################
open_run synth_1

###############################
## Set the name of the ILA core
###############################
set ilaName u_ila_0

##################
## Create the core
##################
CreateDebugCore ${ilaName}

#######################
## Set the record depth
#######################
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]
# set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/clinkClk}
# SetDebugCoreClk ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/sysClk}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/rstFsm}

ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/parValid}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/parClock[*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/parReady}

ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[state][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[delayLd]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[bitSlip]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[count][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[delay][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[lastClk][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[status][delay][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[status][shiftCnt][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/r[status][locked]}

ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/linkStatus[locked]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/linkStatus[delay][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Cbl0Half1/linkStatus[shiftCnt][*]}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 
