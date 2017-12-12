##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'Example Project Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################
#
# I/O Port Mapping
set_property PACKAGE_PIN AB7 [get_ports extRst]
set_property IOSTANDARD LVCMOS15 [get_ports extRst]

set_property PACKAGE_PIN AB8  [get_ports {led[0]}]
set_property PACKAGE_PIN AA8  [get_ports {led[1]}]
set_property PACKAGE_PIN AC9  [get_ports {led[2]}]
set_property PACKAGE_PIN AB9  [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports led[0]]
set_property IOSTANDARD LVCMOS15 [get_ports led[1]]
set_property IOSTANDARD LVCMOS15 [get_ports led[2]]
set_property IOSTANDARD LVCMOS15 [get_ports led[3]]

set_property PACKAGE_PIN AE26 [get_ports {led[4]}]
set_property PACKAGE_PIN G19  [get_ports {led[5]}]
set_property PACKAGE_PIN E18  [get_ports {led[6]}]
set_property PACKAGE_PIN F16  [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports led[4]]
set_property IOSTANDARD LVCMOS25 [get_ports led[5]]
set_property IOSTANDARD LVCMOS25 [get_ports led[6]]
set_property IOSTANDARD LVCMOS25 [get_ports led[7]]

set_property PACKAGE_PIN H2 [get_ports gtTxP]
set_property PACKAGE_PIN H1 [get_ports gtTxN]
set_property PACKAGE_PIN G4 [get_ports gtRxP]
set_property PACKAGE_PIN G3 [get_ports gtRxN]

set_property PACKAGE_PIN G8 [get_ports gtClkP]
set_property PACKAGE_PIN G7 [get_ports gtClkN]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half0P[0]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half0P[0]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half0P[1]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half0P[1]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half0P[2]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half0P[2]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half0P[3]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half0P[3]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half0P[4]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half0P[4]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half1P[0]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half1P[0]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half1P[1]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half1P[1]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half1P[2]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half1P[2]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half1P[3]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half1P[3]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl0Half1P[4]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl0Half1P[4]}]

set_property IOSTANDARD  LVDS_25  [get_ports {cbl0SerP}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half0P[0]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half0P[0]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half0P[1]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half0P[1]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half0P[2]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half0P[2]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half0P[3]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half0P[3]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half0P[4]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half0P[4]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half1P[0]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half1P[0]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half1P[1]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half1P[1]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half1P[2]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half1P[2]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half1P[3]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half1P[3]}]

set_property DIFF_TERM   TRUE     [get_ports {cbl1Half1P[4]}]
set_property IOSTANDARD  LVDS_25  [get_ports {cbl1Half1P[4]}]

set_property IOSTANDARD  LVDS_25  [get_ports {cbl1SerP}]

##############################################################
# HPC Connector
##############################################################

#set_property PACKAGE_PIN E19      [get_ports {cbl0Half0P[0]}]
#set_property PACKAGE_PIN D19      [get_ports {cbl0Half0N[0]}]
#
#set_property PACKAGE_PIN B28      [get_ports {cbl0Half0P[1]}]
#set_property PACKAGE_PIN A28      [get_ports {cbl0Half0N[1]}]
#
#set_property PACKAGE_PIN F21      [get_ports {cbl0Half0P[2]}]
#set_property PACKAGE_PIN E21      [get_ports {cbl0Half0N[2]}]
#
#set_property PACKAGE_PIN G18      [get_ports {cbl0Half0P[3]}]
#set_property PACKAGE_PIN f18      [get_ports {cbl0Half0N[3]}]
#
#set_property PACKAGE_PIN A20      [get_ports {cbl0Half0P[4]}]
#set_property PACKAGE_PIN A21      [get_ports {cbl0Half0N[4]}]
#
#set_property PACKAGE_PIN C25      [get_ports {cbl0Half1P[0]}]
#set_property PACKAGE_PIN B25      [get_ports {cbl0Half1N[0]}]
#
#set_property PACKAGE_PIN H24      [get_ports {cbl0Half1P[1]}]
#set_property PACKAGE_PIN H25      [get_ports {cbl0Half1N[1]}]
#
#set_property PACKAGE_PIN H26      [get_ports {cbl0Half1P[2]}]
#set_property PACKAGE_PIN H27      [get_ports {cbl0Half1N[2]}]
#
#set_property PACKAGE_PIN G28      [get_ports {cbl0Half1P[3]}]
#set_property PACKAGE_PIN F28      [get_ports {cbl0Half1N[3]}]
#
#set_property PACKAGE_PIN G29      [get_ports {cbl0Half1P[4]}]
#set_property PACKAGE_PIN F30      [get_ports {cbl0Half1N[4]}]
#
#set_property PACKAGE_PIN C24      [get_ports {cbl0SerP}]
#set_property PACKAGE_PIN B24      [get_ports {cbl0SerN}]
#
#set_property PACKAGE_PIN F20      [get_ports {cbl1Half0P[0]}]
#set_property PACKAGE_PIN E20      [get_ports {cbl1Half0N[0]}]
#
#set_property PACKAGE_PIN D29      [get_ports {cbl1Half0P[1]}]
#set_property PACKAGE_PIN C30      [get_ports {cbl1Half0N[1]}]
#
#set_property PACKAGE_PIN G27      [get_ports {cbl1Half0P[2]}]
#set_property PACKAGE_PIN F27      [get_ports {cbl1Half0N[2]}]
#
#set_property PACKAGE_PIN C29      [get_ports {cbl1Half0P[3]}]
#set_property PACKAGE_PIN B29      [get_ports {cbl1Half0N[3]}]
#
#set_property PACKAGE_PIN A25      [get_ports {cbl1Half0P[4]}]
#set_property PACKAGE_PIN A26      [get_ports {cbl1Half0N[4]}]
#
#set_property PACKAGE_PIN D26      [get_ports {cbl1Half1P[0]}]
#set_property PACKAGE_PIN C26      [get_ports {cbl1Half1N[0]}]
#
#set_property PACKAGE_PIN H30      [get_ports {cbl1Half1P[1]}]
#set_property PACKAGE_PIN G30      [get_ports {cbl1Half1N[1]}]
#
#set_property PACKAGE_PIN E28      [get_ports {cbl1Half1P[2]}]
#set_property PACKAGE_PIN D28      [get_ports {cbl1Half1N[2]}]
#
#set_property PACKAGE_PIN E29      [get_ports {cbl1Half1P[3]}]
#set_property PACKAGE_PIN E30      [get_ports {cbl1Half1N[3]}]
#
#set_property PACKAGE_PIN B30      [get_ports {cbl1Half1P[4]}]
#set_property PACKAGE_PIN A30      [get_ports {cbl1Half1N[4]}]
#
#set_property PACKAGE_PIN B27      [get_ports {cbl1SerP}]
#set_property PACKAGE_PIN A27      [get_ports {cbl1SerN}]

##############################################################
# LPC Connector
##############################################################

set_property PACKAGE_PIN AF26     [get_ports {cbl0Half0P[0]}]
set_property PACKAGE_PIN AF27     [get_ports {cbl0Half0N[0]}]

set_property PACKAGE_PIN AD21     [get_ports {cbl0Half0P[1]}]
set_property PACKAGE_PIN AE21     [get_ports {cbl0Half0N[1]}]

set_property PACKAGE_PIN AD27     [get_ports {cbl0Half0P[2]}]
set_property PACKAGE_PIN AD28     [get_ports {cbl0Half0N[2]}]

set_property PACKAGE_PIN AJ26     [get_ports {cbl0Half0P[3]}]
set_property PACKAGE_PIN AK26     [get_ports {cbl0Half0N[3]}]

set_property PACKAGE_PIN AG27     [get_ports {cbl0Half0P[4]}]
set_property PACKAGE_PIN AG28     [get_ports {cbl0Half0N[4]}]

set_property PACKAGE_PIN AD23     [get_ports {cbl0Half1P[0]}]
set_property PACKAGE_PIN AE24     [get_ports {cbl0Half1N[0]}]

set_property PACKAGE_PIN AF20     [get_ports {cbl0Half1P[1]}]
set_property PACKAGE_PIN AF21     [get_ports {cbl0Half1N[1]}]

set_property PACKAGE_PIN AG20     [get_ports {cbl0Half1P[2]}]
set_property PACKAGE_PIN AH20     [get_ports {cbl0Half1N[2]}]

set_property PACKAGE_PIN AH21     [get_ports {cbl0Half1P[3]}]
set_property PACKAGE_PIN AJ21     [get_ports {cbl0Half1N[3]}]

set_property PACKAGE_PIN AG22     [get_ports {cbl0Half1P[4]}]
set_property PACKAGE_PIN AH22     [get_ports {cbl0Half1N[4]}]

set_property PACKAGE_PIN AC24     [get_ports {cbl0SerP}]
set_property PACKAGE_PIN AD24     [get_ports {cbl0SerN}]

set_property PACKAGE_PIN AB27     [get_ports {cbl1Half0P[0]}]
set_property PACKAGE_PIN AC27     [get_ports {cbl1Half0N[0]}]

set_property PACKAGE_PIN AJ24     [get_ports {cbl1Half0P[1]}]
set_property PACKAGE_PIN AK25     [get_ports {cbl1Half0N[1]}]

set_property PACKAGE_PIN AE25     [get_ports {cbl1Half0P[2]}]
set_property PACKAGE_PIN AF25     [get_ports {cbl1Half0N[2]}]

set_property PACKAGE_PIN AA20     [get_ports {cbl1Half0P[3]}]
set_property PACKAGE_PIN AB20     [get_ports {cbl1Half0N[3]}]

set_property PACKAGE_PIN AB24     [get_ports {cbl1Half0P[4]}]
set_property PACKAGE_PIN AC25     [get_ports {cbl1Half0N[4]}]

set_property PACKAGE_PIN AE23     [get_ports {cbl1Half1P[0]}]
set_property PACKAGE_PIN AF23     [get_ports {cbl1Half1N[0]}]

set_property PACKAGE_PIN AK20     [get_ports {cbl1Half1P[1]}]
set_property PACKAGE_PIN AK21     [get_ports {cbl1Half1N[1]}]

set_property PACKAGE_PIN AG25     [get_ports {cbl1Half1P[2]}]
set_property PACKAGE_PIN AH25     [get_ports {cbl1Half1N[2]}]

set_property PACKAGE_PIN AJ22     [get_ports {cbl1Half1P[3]}]
set_property PACKAGE_PIN AJ23     [get_ports {cbl1Half1N[3]}]

set_property PACKAGE_PIN AK23     [get_ports {cbl1Half1P[4]}]
set_property PACKAGE_PIN AK24     [get_ports {cbl1Half1N[4]}]

set_property PACKAGE_PIN AC22     [get_ports {cbl1SerP}]
set_property PACKAGE_PIN AD22     [get_ports {cbl1SerN}]


# Timing Constraints 
create_clock -name gtClkP -period 8.000 [get_ports {gtClkP}]

create_generated_clock -name stableClk  [get_pins {U_PGP/IBUFDS_GTE2_Inst/ODIV2}]
create_generated_clock -name pgpClk     [get_pins {U_PGP/ClockManager7_Inst/MmcmGen.U_Mmcm/CLKOUT0}] 
create_generated_clock -name dnaClk     [get_pins {U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}] 
create_generated_clock -name dnaClkInv  [get_pins {U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}] 

set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {stableClk}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {dnaClk}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {dnaClkInv}] 

# Clink clock inputs
create_clock -name cbl0Half1Clk0 -period 10 [get_ports {cbl0Half1P[0]}]
create_clock -name cbl1Half0Clk0 -period 10 [get_ports {cbl1Half0P[0]}]
create_clock -name cbl1Half1Clk0 -period 10 [get_ports {cbl1Half1P[0]}]

set_input_jitter [get_ports -of_objects cbl0Half1Clk0]
set_input_jitter [get_ports -of_objects cbl1Half0Clk0]
set_input_jitter [get_ports -of_objects cbl1Half1Clk0]

# Clink derived clocks - MMCM
create_generated_clock -name cbl0Half1Clk1 [get_pins {U_ClinkTop/U_Cbl0Half1/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT0}] 
create_generated_clock -name cbl0Half1Clk2 [get_pins {U_ClinkTop/U_Cbl0Half1/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT1}] 

create_generated_clock -name cbl1Half0Clk1 [get_pins {U_ClinkTop/U_DualCtrl*.U_Cbl1Half0/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT0}] 
create_generated_clock -name cbl1Half0Clk2 [get_pins {U_ClinkTop/U_DualCtrl*.U_Cbl1Half0/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT1}] 

create_generated_clock -name cbl1Half1Clk1 [get_pins {U_ClinkTop/U_Cbl1Half1/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT0}] 
create_generated_clock -name cbl1Half1Clk2 [get_pins {U_ClinkTop/U_Cbl1Half1/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT1}] 

# Clink clocks async to internal clock
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl0Half1Clk0}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl0Half1Clk1}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl0Half1Clk2}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl1Half0Clk0}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl1Half0Clk1}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl1Half0Clk2}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl1Half1Clk0}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl1Half1Clk1}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {cbl1Half1Clk2}] 

# Clink input clock async to derived clocks (for clock input shift)
set_clock_groups -asynchronous -group [get_clocks {cbl0Half1Clk0}] -group [get_clocks {cbl0Half1Clk2}]

# Clink input clock async to derived clocks (for clock input shift)
set_clock_groups -asynchronous -group [get_clocks {cbl1Half0Clk0}] -group [get_clocks {cbl1Half0Clk2}]

# Clink input clock async to derived clocks (for clock input shift)
set_clock_groups -asynchronous -group [get_clocks {cbl1Half1Clk0}] -group [get_clocks {cbl1Half1Clk2}]

# Clink Clock
create_generated_clock -name dlyClk [get_pins {U_ClkGen/MmcmGen.U_Mmcm/CLKOUT0}] 

# Clink clocks async to other clocks 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {stableClk}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {dnaClk}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {dnaClkInv}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {pgpClk}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl0Half1Clk0}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl0Half1Clk1}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl0Half1Clk2}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl1Half0Clk0}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl1Half0Clk1}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl1Half0Clk2}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl1Half1Clk0}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl1Half1Clk1}] 
set_clock_groups -asynchronous -group [get_clocks {dlyClk}] -group [get_clocks {cbl1Half1Clk2}] 

# .bit File Configuration
set_property BITSTREAM.CONFIG.CONFIGRATE 9 [current_design]  
