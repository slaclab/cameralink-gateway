##############################################################################
## This file is part of LCLS2 PGP Firmware Library'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of LCLS2 PGP Firmware Library', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_HSIO/U_TimingRx/gtRxClk_0]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_HSIO/U_TimingRx/gtRxClk_1]

set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_HSIO/U_TimingRx/gtTxClk_0]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_HSIO/U_TimingRx/gtTxClk_1]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/clkOut[0]]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_Pll/clkOut[0]]

# PGP Clocks

create_clock -name pgpRxClk0 -period 6.400 [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/RXOUTCLK}]
create_clock -name pgpRxClk1 -period 6.400 [get_pins {U_HSIO/GEN_LANE[1].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/RXOUTCLK}]
create_clock -name pgpRxClk2 -period 6.400 [get_pins {U_HSIO/GEN_LANE[2].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/RXOUTCLK}]
create_clock -name pgpRxClk3 -period 6.400 [get_pins {U_HSIO/GEN_LANE[3].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/RXOUTCLK}]

create_clock -name pgpTxClk0 -period 6.400 [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/TXOUTCLK}]
create_clock -name pgpTxClk1 -period 6.400 [get_pins {U_HSIO/GEN_LANE[1].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/TXOUTCLK}]
create_clock -name pgpTxClk2 -period 6.400 [get_pins {U_HSIO/GEN_LANE[2].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/TXOUTCLK}]
create_clock -name pgpTxClk3 -period 6.400 [get_pins {U_HSIO/GEN_LANE[3].U_Lane/REAL_PGP.U_Pgp/MuliLane_Inst/GTP7_CORE_GEN[0].Gtp7Core_Inst/gtpe2_i/TXOUTCLK}]

# Base Clocks 

create_generated_clock -name clk119 [get_pins {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/PllGen.U_Pll/CLKOUT0}] 
create_generated_clock -name clk186 [get_pins {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_Pll/PllGen.U_Pll/CLKOUT0}]

# GT Out Clocks

create_clock -name timingGtRxOutClk0 -period 8.402 [get_pins {U_HSIO/U_TimingRx/GEN_VEC[0].REAL_PCIE.U_GTP/U_Gtp/gtpe2_i/RXOUTCLK}]
create_clock -name timingGtTxOutClk0 -period 8.402 [get_pins {U_HSIO/U_TimingRx/GEN_VEC[0].REAL_PCIE.U_GTP/U_Gtp/gtpe2_i/TXOUTCLK}]

create_clock -name timingGtRxOutClk1 -period 5.382 [get_pins {U_HSIO/U_TimingRx/GEN_VEC[1].REAL_PCIE.U_GTP/U_Gtp/gtpe2_i/RXOUTCLK}]
create_clock -name timingGtTxOutClk1 -period 5.382 [get_pins {U_HSIO/U_TimingRx/GEN_VEC[1].REAL_PCIE.U_GTP/U_Gtp/gtpe2_i/TXOUTCLK}]

# Cascaded clock muxing - GEN_VEC[0] RX mux
create_generated_clock -name muxRxClk119 \
    -divide_by 1 -add -master_clock clk119 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_RXCLK/I1}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_RXCLK/O}]

create_generated_clock -name muxTimingGtRxOutClk0 \
    -divide_by 1 -add -master_clock timingGtRxOutClk0 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_RXCLK/I0}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_RXCLK/O}]

set_clock_groups -physically_exclusive -group muxTimingGtRxOutClk0 -group muxRxClk119
set_false_path -to [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_RXCLK/CE*}]

# Cascaded clock muxing - GEN_VEC[0] TX mux
create_generated_clock -name muxTxClk119 \
    -divide_by 1 -add -master_clock clk119 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_TXCLK/I1}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_TXCLK/O}]

create_generated_clock -name muxTimingTxOutClk0 \
    -divide_by 1 -add -master_clock timingGtTxOutClk0 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_TXCLK/I0}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_TXCLK/O}]

set_clock_groups -physically_exclusive -group muxTimingTxOutClk0 -group muxTxClk119
set_false_path -to [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[0].U_TXCLK/CE*}]

# Cascaded clock muxing - GEN_VEC[1] RX mux
create_generated_clock -name muxRxClk186 \
    -divide_by 1 -add -master_clock clk186 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_RXCLK/I1}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_RXCLK/O}]

create_generated_clock -name muxTimingGtRxOutClk1 \
    -divide_by 1 -add -master_clock timingGtRxOutClk1 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_RXCLK/I0}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_RXCLK/O}]

set_clock_groups -physically_exclusive -group muxTimingGtRxOutClk1 -group muxRxClk186
set_false_path -to [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_RXCLK/CE*}]

# Cascaded clock muxing - GEN_VEC[1] TX mux
create_generated_clock -name muxTxClk186 \
    -divide_by 1 -add -master_clock clk186 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_TXCLK/I1}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_TXCLK/O}]

create_generated_clock -name muxTimingTxOutClk1 \
    -divide_by 1 -add -master_clock timingGtTxOutClk1 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_TXCLK/I0}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_TXCLK/O}]

set_clock_groups -physically_exclusive -group muxTimingTxOutClk1 -group muxTxClk186
set_false_path -to [get_pins -hier -filter {name =~ */U_TimingRx/GEN_VEC[1].U_TXCLK/CE*}]

# Cascaded clock muxing - Final RX mux
create_generated_clock -name casMuxRxClk119 \
    -divide_by 1 -add -master_clock muxRxClk119 \
    -source [get_pins {*/U_TimingRx/U_RXCLK/I0}] \
    [get_pins {*/U_TimingRx/U_RXCLK/O}]

create_generated_clock -name casMuxTimingGtRxOutClk0 \
    -divide_by 1 -add -master_clock muxTimingGtRxOutClk0 \
    -source [get_pins {*/U_TimingRx/U_RXCLK/I0}] \
    [get_pins {*/U_TimingRx/U_RXCLK/O}]

create_generated_clock -name casMuxRxClk186 \
    -divide_by 1 -add -master_clock muxRxClk186 \
    -source [get_pins {*/U_TimingRx/U_RXCLK/I1}] \
    [get_pins {*/U_TimingRx/U_RXCLK/O}]

create_generated_clock -name casMuxTimingGtRxOutClk1 \
    -divide_by 1 -add -master_clock muxTimingGtRxOutClk1 \
    -source [get_pins {*/U_TimingRx/U_RXCLK/I1}] \
    [get_pins {*/U_TimingRx/U_RXCLK/O}]

set_clock_groups -physically_exclusive \
    -group casMuxRxClk119 \
    -group casMuxTimingGtRxOutClk0 \
    -group casMuxRxClk186 \
    -group casMuxTimingGtRxOutClk1

set_false_path -to [get_pins {*/U_TimingRx/U_RXCLK/CE*}]

# Cascaded clock muxing - Final TX mux
create_generated_clock -name casMuxTxClk119 \
    -divide_by 1 -add -master_clock muxTxClk119 \
    -source [get_pins {*/U_TimingRx/U_TXCLK/I0}] \
    [get_pins {*/U_TimingRx/U_TXCLK/O}]

create_generated_clock -name casMuxTimingTxOutClk0 \
    -divide_by 1 -add -master_clock muxTimingTxOutClk0 \
    -source [get_pins {*/U_TimingRx/U_TXCLK/I0}] \
    [get_pins {*/U_TimingRx/U_TXCLK/O}]

create_generated_clock -name casMuxTxClk186 \
    -divide_by 1 -add -master_clock muxTxClk186 \
    -source [get_pins {*/U_TimingRx/U_TXCLK/I1}] \
    [get_pins {*/U_TimingRx/U_TXCLK/O}]

create_generated_clock -name casMuxTimingTxOutClk1 \
    -divide_by 1 -add -master_clock muxTimingTxOutClk1 \
    -source [get_pins {*/U_TimingRx/U_TXCLK/I1}] \
    [get_pins {*/U_TimingRx/U_TXCLK/O}]

set_clock_groups -physically_exclusive \
    -group casMuxTxClk119 \
    -group casMuxTimingTxOutClk0
    -group casMuxTxClk186 \
    -group casMuxTimingTxOutClk1

set_false_path -to [get_pins {*/U_TimingRx/U_TXCLK/CE*}]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks {pgpRefClk}] \
    -group [get_clocks -include_generated_clocks {timingGtRxOutClk0}] \
    -group [get_clocks -include_generated_clocks {timingGtRxOutClk1}] \    
    -group [get_clocks -include_generated_clocks {timingGtTxOutClk0}] \
    -group [get_clocks -include_generated_clocks {timingGtTxOutClk1}] \
    -group [get_clocks -include_generated_clocks {evrRefClk0}]  \
    -group [get_clocks -include_generated_clocks {evrRefClk1}] \
    -group [get_clocks -include_generated_clocks {sysClk}] 

set_clock_groups -asynchronous -group [get_clocks {pgpRxClk0}] -group [get_clocks {pgpTxClk0}] -group [get_clocks -include_generated_clocks {sysClk}] 
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk1}] -group [get_clocks {pgpTxClk1}] -group [get_clocks -include_generated_clocks {sysClk}] 
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk2}] -group [get_clocks {pgpTxClk2}] -group [get_clocks -include_generated_clocks {sysClk}] 
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk3}] -group [get_clocks {pgpTxClk3}] -group [get_clocks -include_generated_clocks {sysClk}] 

####################################################################################
# Note: This list of BUFG locations generated for a "good" build that passed timing:
####################################################################################
#   foreach idx [get_cells -hier -filter {IS_PRIMITIVE && (REF_NAME =~ BUFG*)}] {
#      set LOC [get_property LOC [get_cells ${idx}]]
#      puts "set_property LOC ${LOC} \[get_cells \{${idx}\}\]"
#   }
####################################################################################

set_property LOC BUFGCTRL_X0Y31 [get_cells {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/cpllpd_refclk_inst}]
set_property LOC BUFGCTRL_X0Y27 [get_cells {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/dclk_i_bufg.dclk_i}]
set_property LOC BUFGCTRL_X0Y26 [get_cells {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1}]
set_property LOC BUFGCTRL_X0Y30 [get_cells {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/txoutclk_i.txoutclk_i}]
set_property LOC BUFGCTRL_X0Y25 [get_cells {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/userclk1_i1.usrclk1_i1}]
set_property LOC BUFGCTRL_X0Y24 [get_cells {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/userclk2_i1.usrclk2_i1}]
# set_property LOC BUFGCTRL_X0Y14 [get_cells {U_HSIO/U_txPllClk0}]
# set_property LOC BUFGCTRL_X0Y15 [get_cells {U_HSIO/U_txPllClk1}]
# set_property LOC BUFGCTRL_X0Y16 [get_cells {U_HSIO/U_txPllClk2}]
# set_property LOC BUFGCTRL_X0Y13 [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_Bufg}]
# set_property LOC BUFGCTRL_X0Y23 [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_rxPllClk1}]
# set_property LOC BUFGCTRL_X0Y22 [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_rxPllClk2}]
# set_property LOC BUFGCTRL_X0Y12 [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/rxout0_i}]
set_property LOC BUFGCTRL_X0Y1 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[0].U_RXCLK}]
set_property LOC BUFGCTRL_X0Y3 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[0].U_TXCLK}]
set_property LOC BUFGCTRL_X0Y5 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[1].U_RXCLK}]
set_property LOC BUFGCTRL_X0Y7 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[1].U_TXCLK}]
set_property LOC BUFGCTRL_X0Y8 [get_cells {U_HSIO/U_TimingRx/U_RXCLK}]
set_property LOC BUFGCTRL_X0Y10 [get_cells {U_HSIO/U_TimingRx/U_TXCLK}]
set_property LOC BUFGCTRL_X0Y29 [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/InputBufgGen.U_Bufg}]
set_property LOC BUFGCTRL_X0Y9 [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/OutBufgGen.ClkOutGen[0].U_Bufg}]
set_property LOC BUFGCTRL_X0Y28 [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_Pll/InputBufgGen.U_Bufg}]
set_property LOC BUFGCTRL_X0Y11 [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_Pll/OutBufgGen.ClkOutGen[0].U_Bufg}]
set_property LOC BUFGCTRL_X0Y2 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[0].REAL_PCIE.U_GTP/TxBUFG_Inst}]
set_property LOC BUFGCTRL_X0Y0 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[0].REAL_PCIE.U_GTP/U_Gtp/BUFG_RX_OUT_CLK}]
set_property LOC BUFGCTRL_X0Y6 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[1].REAL_PCIE.U_GTP/TxBUFG_Inst}]
set_property LOC BUFGCTRL_X0Y4 [get_cells {U_HSIO/U_TimingRx/GEN_VEC[1].REAL_PCIE.U_GTP/U_Gtp/BUFG_RX_OUT_CLK}]
