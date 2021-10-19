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

# set_property LOC MMCME2_ADV_X0Y0 [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/MmcmGen.U_Mmcm}]
# set_property LOC PLLE2_ADV_X0Y0  [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_Pll/PllGen.U_Pll}]
# set_property LOC BUFHCE_X0Y0 [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_CLK_BUF}]
# set_property LOC BUFHCE_X0Y1 [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_CLK_BUF}]

# set_property LOC MMCME2_ADV_X1Y0  [get_cells {U_HSIO/U_TX_PLL/MmcmGen.U_Mmcm}]
# set_property LOC BUFR_X1Y0 [get_cells {U_HSIO/U_txPllClk0}]
# set_property LOC BUFR_X1Y1 [get_cells {U_HSIO/U_txPllClk1}]
# set_property LOC BUFR_X1Y2 [get_cells {U_HSIO/U_txPllClk2}]
# set_property LOC BUFHCE_X1Y0 [get_cells {U_HSIO/U_txPllClkIn}]

# set_property LOC PLLE2_ADV_X1Y0  [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL}]

# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/InputBufgGen.U_Bufg}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/OutBufgGen.ClkOutGen[0].U_Bufg}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_Pll/InputBufgGen.U_Bufg}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_Pll/OutBufgGen.ClkOutGen[0].U_Bufg}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_VEC[0].U_RXCLK}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_VEC[1].U_RXCLK}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/U_RXCLK}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/U_TXCLK}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_VEC[0].REAL_PCIE.U_GTP/TxBUFG_Inst}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_VEC[1].REAL_PCIE.U_GTP/TxBUFG_Inst}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_VEC[0].REAL_PCIE.U_GTP/U_Gtp/BUFG_RX_OUT_CLK}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/U_TimingRx/GEN_VEC[1].REAL_PCIE.U_GTP/U_Gtp/BUFG_RX_OUT_CLK}]

# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/rxout0_i}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_Bufg}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_rxPllClk1}]
# set_property LOC BUFGCE_XZYZZ [get_cells {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_rxPllClk2}]

# Base Clocks

create_generated_clock -name clk119 [get_pins {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_Pll/MmcmGen.U_Mmcm/CLKOUT0}]
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

# Clock muxing - TX mux
create_generated_clock -name muxTxClk186 \
    -divide_by 1 -add -master_clock clk186 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/U_TXCLK/I1}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/U_TXCLK/O}]

create_generated_clock -name muxTimingTxOutClk1 \
    -divide_by 1 -add -master_clock timingGtTxOutClk1 \
    -source [get_pins -hier -filter {name =~ */U_TimingRx/U_TXCLK/I0}] \
    [get_pins -hier -filter {name =~ */U_TimingRx/U_TXCLK/O}]

set_clock_groups -physically_exclusive -group muxTimingTxOutClk1 -group muxTxClk186
set_false_path -to [get_pins -hier -filter {name =~ */U_TimingRx/U_TXCLK/CE*}]

##############################################################################

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks {pgpRefClk}] \
    -group [get_clocks -include_generated_clocks {timingGtRxOutClk0}] \
    -group [get_clocks -include_generated_clocks {timingGtRxOutClk1}] \
    -group [get_clocks -include_generated_clocks {timingGtTxOutClk0}] \
    -group [get_clocks -include_generated_clocks {timingGtTxOutClk1}] \
    -group [get_clocks -include_generated_clocks {evrRefClk0}]  \
    -group [get_clocks -include_generated_clocks {evrRefClk1}] \
    -group [get_clocks -include_generated_clocks {sysClk}]

#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_HSIO/U_TX_PLL/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_HSIO/U_TX_PLL/CLKOUT2]]
#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_HSIO/U_TX_PLL/CLKOUT0]] -group [get_clocks -of_objects [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]] -group [get_clocks -of_objects [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT1}]]
#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]] -group [get_clocks -of_objects [get_pins U_HSIO/U_TX_PLL/CLKOUT0]]
#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]] -group [get_clocks -of_objects [get_pins U_HSIO/U_TX_PLL/CLKOUT1]]
set_clock_groups -asynchronous -group [get_clocks {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/Pgp3Gtp7Ip6G_i/gt0_Pgp3Gtp7Ip6G_i/gtpe2_i/RXOUTCLK}] -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]] -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]]
#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_HSIO/U_TX_PLL/CLKOUT2]] -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]] -group [get_clocks -of_objects [get_pins U_HSIO/U_txPllClk0/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]] -group [get_clocks -of_objects [get_pins U_HSIO/U_txPllClk1/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]] -group [get_clocks -of_objects [get_pins U_HSIO/U_txPllClk0/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_HSIO/U_txPllClk2/O]] -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_HSIO/U_txPllClk0/O]] -group [get_clocks -of_objects [get_pins U_HSIO/U_txPllClk2/O]]
