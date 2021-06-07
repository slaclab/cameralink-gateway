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
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/sysClk}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/chanConfig[dataMode][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/chanConfig[frameMode][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/chanConfig[linkMode][*]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/chanConfig[tapCount][*]}

ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[master][tUser][72]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[master][tUser][73]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/intCtrl[overflow]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/intCtrl[pause]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/packMaster[tLast]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/packMaster[tValid]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/parReady}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[byteData][dv]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[byteData][fv]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[byteData][lv]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[byteData][valid]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[dump]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[inFrame]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[master][tLast]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[master][tValid]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[portData][dv]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[portData][fv]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[portData][lv]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[portData][valid]}
ConfigProbe ${ilaName} {U_Core/U_CLinkWrapper/U_ClinkTop/U_Framer0/r[ready]}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName}
