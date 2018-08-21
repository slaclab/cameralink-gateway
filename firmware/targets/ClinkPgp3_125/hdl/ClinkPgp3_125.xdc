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
set_property PACKAGE_PIN G20  [get_ports {ledRed[0]}]
set_property PACKAGE_PIN L18  [get_ports {ledGrn[0]}]
set_property PACKAGE_PIN F20  [get_ports {ledBlu[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports ledRed[0]]
set_property IOSTANDARD LVCMOS15 [get_ports ledGrn[0]]
set_property IOSTANDARD LVCMOS15 [get_ports ledBlu[0]]

set_property PACKAGE_PIN E21  [get_ports {ledRed[1]}]
set_property PACKAGE_PIN H22  [get_ports {ledGrn[1]}]
set_property PACKAGE_PIN E22  [get_ports {ledBlu[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports ledRed[1]]
set_property IOSTANDARD LVCMOS15 [get_ports ledGrn[1]]
set_property IOSTANDARD LVCMOS15 [get_ports ledBlu[1]]

set_property PACKAGE_PIN F2 [get_ports gtTxP]
set_property PACKAGE_PIN F1 [get_ports gtTxN]
set_property PACKAGE_PIN G4 [get_ports gtRxP]
set_property PACKAGE_PIN G3 [get_ports gtRxN]

set_property PACKAGE_PIN D6 [get_ports gtClkP]
set_property PACKAGE_PIN D5 [get_ports gtClkN]

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

set_property PACKAGE_PIN Y18      [get_ports {cbl0Half0P[0]}]
set_property PACKAGE_PIN Y19      [get_ports {cbl0Half0M[0]}]

set_property PACKAGE_PIN AA14     [get_ports {cbl0Half0P[1]}]
set_property PACKAGE_PIN AA15     [get_ports {cbl0Half0M[1]}]

set_property PACKAGE_PIN R16      [get_ports {cbl0Half0P[2]}]
set_property PACKAGE_PIN T16      [get_ports {cbl0Half0M[2]}]

set_property PACKAGE_PIN W14      [get_ports {cbl0Half0P[3]}]
set_property PACKAGE_PIN Y14      [get_ports {cbl0Half0M[3]}]

set_property PACKAGE_PIN T15      [get_ports {cbl0Half0P[4]}]
set_property PACKAGE_PIN U15      [get_ports {cbl0Half0M[4]}]

set_property PACKAGE_PIN V19      [get_ports {cbl0Half1P[0]}]
set_property PACKAGE_PIN W19      [get_ports {cbl0Half1M[0]}]

set_property PACKAGE_PIN T21      [get_ports {cbl0Half1P[1]}]
set_property PACKAGE_PIN U21      [get_ports {cbl0Half1M[1]}]

set_property PACKAGE_PIN T18      [get_ports {cbl0Half1P[2]}]
set_property PACKAGE_PIN U18      [get_ports {cbl0Half1M[2]}]

set_property PACKAGE_PIN U17      [get_ports {cbl0Half1P[3]}]
set_property PACKAGE_PIN V18      [get_ports {cbl0Half1M[3]}]

set_property PACKAGE_PIN Y21      [get_ports {cbl0Half1P[4]}]
set_property PACKAGE_PIN Y22      [get_ports {cbl0Half1M[4]}]

set_property PACKAGE_PIN AB15     [get_ports {cbl0SerP}]
set_property PACKAGE_PIN AB16     [get_ports {cbl0SerM}]

set_property PACKAGE_PIN E17      [get_ports {cbl1Half0P[0]}]
set_property PACKAGE_PIN E18      [get_ports {cbl1Half0M[0]}]

set_property PACKAGE_PIN D19      [get_ports {cbl1Half0P[1]}]
set_property PACKAGE_PIN D20      [get_ports {cbl1Half0M[1]}]

set_property PACKAGE_PIN B18      [get_ports {cbl1Half0P[2]}]
set_property PACKAGE_PIN A19      [get_ports {cbl1Half0M[2]}]

set_property PACKAGE_PIN A20      [get_ports {cbl1Half0P[3]}]
set_property PACKAGE_PIN A21      [get_ports {cbl1Half0M[3]}]

set_property PACKAGE_PIN B20      [get_ports {cbl1Half0P[4]}]
set_property PACKAGE_PIN B21      [get_ports {cbl1Half0M[4]}]

set_property PACKAGE_PIN C17      [get_ports {cbl1Half1P[0]}]
set_property PACKAGE_PIN C18      [get_ports {cbl1Half1M[0]}]

set_property PACKAGE_PIN G15      [get_ports {cbl1Half1P[1]}]
set_property PACKAGE_PIN G16      [get_ports {cbl1Half1M[1]}]

set_property PACKAGE_PIN F15      [get_ports {cbl1Half1P[2]}]
set_property PACKAGE_PIN F16      [get_ports {cbl1Half1M[2]}]

set_property PACKAGE_PIN C13      [get_ports {cbl1Half1P[3]}]
set_property PACKAGE_PIN B13      [get_ports {cbl1Half1M[3]}]

set_property PACKAGE_PIN C14      [get_ports {cbl1Half1P[4]}]
set_property PACKAGE_PIN C15      [get_ports {cbl1Half1M[4]}]

set_property PACKAGE_PIN J16      [get_ports {cbl1SerP}]
set_property PACKAGE_PIN J17      [get_ports {cbl1SerM}]

# Timing Constraints 
create_clock -name gtClkP -period 3.2 [get_ports {gtClkP}]

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

create_generated_clock -name cbl1Half0Clk1 [get_pins {U_ClinkTop/U_DualCtrlDis.U_Cbl1Half0/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT0}] 
create_generated_clock -name cbl1Half0Clk2 [get_pins {U_ClinkTop/U_DualCtrlDis.U_Cbl1Half0/U_DataShift/U_ClkGen/U_Mmcm/CLKOUT1}] 

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
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design] 
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE No [current_design]
