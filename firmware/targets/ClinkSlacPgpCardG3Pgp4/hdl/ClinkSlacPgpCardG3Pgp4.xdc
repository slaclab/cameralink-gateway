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

set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_HSIO/U_TimingRx/refClk_0]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_HSIO/U_TimingRx/refClk_1]

# PGP Clocks

create_generated_clock -name pgpRxClk1x_0  [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT0}]
create_generated_clock -name pgpRxClk2x_0  [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]
create_generated_clock -name pgpRxClk4x_0  [get_pins {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT1}]

create_generated_clock -name pgpRxClk1x_1  [get_pins {U_HSIO/GEN_LANE[1].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT0}]
create_generated_clock -name pgpRxClk2x_1  [get_pins {U_HSIO/GEN_LANE[1].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]
create_generated_clock -name pgpRxClk4x_1  [get_pins {U_HSIO/GEN_LANE[1].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT1}]

create_generated_clock -name pgpRxClk1x_2  [get_pins {U_HSIO/GEN_LANE[2].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT0}]
create_generated_clock -name pgpRxClk2x_2  [get_pins {U_HSIO/GEN_LANE[2].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]
create_generated_clock -name pgpRxClk4x_2  [get_pins {U_HSIO/GEN_LANE[2].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT1}]

create_generated_clock -name pgpRxClk1x_3  [get_pins {U_HSIO/GEN_LANE[3].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT0}]
create_generated_clock -name pgpRxClk2x_3  [get_pins {U_HSIO/GEN_LANE[3].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]
create_generated_clock -name pgpRxClk4x_3  [get_pins {U_HSIO/GEN_LANE[3].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT1}]

create_generated_clock -name pgpTxClk1x  [get_pins {U_HSIO/U_TX_PLL/CLKOUT0}]
create_generated_clock -name pgpTxClk2x  [get_pins {U_HSIO/U_TX_PLL/CLKOUT2}]
create_generated_clock -name pgpTxClk4x  [get_pins {U_HSIO/U_TX_PLL/CLKOUT1}]

# Base Clocks 

create_generated_clock -name clk119 [get_pins {U_HSIO/U_TimingRx/GEN_GT_VEC[0].U_IBUFDS/ODIV2}] 
create_generated_clock -name clk186 [get_pins {U_HSIO/U_TimingRx/GEN_GT_VEC[1].U_IBUFDS/ODIV2}]

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

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {sysClk}] -group [get_clocks {U_HSIO/GEN_LANE[0].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/Pgp3Gtp7Ip6G_i/gt0_Pgp3Gtp7Ip6G_i/gtpe2_i/RXOUTCLK}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {sysClk}] -group [get_clocks {U_HSIO/GEN_LANE[1].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/Pgp3Gtp7Ip6G_i/gt0_Pgp3Gtp7Ip6G_i/gtpe2_i/RXOUTCLK}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {sysClk}] -group [get_clocks {U_HSIO/GEN_LANE[2].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/Pgp3Gtp7Ip6G_i/gt0_Pgp3Gtp7Ip6G_i/gtpe2_i/RXOUTCLK}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {sysClk}] -group [get_clocks {U_HSIO/GEN_LANE[3].U_Lane/REAL_PGP.U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/Pgp3Gtp7Ip6G_i/gt0_Pgp3Gtp7Ip6G_i/gtpe2_i/RXOUTCLK}]

set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk1x}] \
   -group [get_clocks {pgpTxClk2x}] \
   -group [get_clocks {pgpRxClk1x_0}] \
   -group [get_clocks {pgpRxClk2x_0}] \
   -group [get_clocks -include_generated_clocks {sysClk}] 

set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk4x}] \
   -group [get_clocks {pgpRxClk4x_0}] \
   -group [get_clocks -include_generated_clocks {sysClk}] 
   
set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk1x}] \
   -group [get_clocks {pgpTxClk2x}] \
   -group [get_clocks {pgpRxClk1x_1}] \
   -group [get_clocks {pgpRxClk2x_1}] \
   -group [get_clocks -include_generated_clocks {sysClk}] 

set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk4x}] \
   -group [get_clocks {pgpRxClk4x_1}] \
   -group [get_clocks -include_generated_clocks {sysClk}]  

set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk1x}] \
   -group [get_clocks {pgpTxClk2x}] \
   -group [get_clocks {pgpRxClk1x_2}] \
   -group [get_clocks {pgpRxClk2x_2}] \
   -group [get_clocks -include_generated_clocks {sysClk}] 

set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk4x}] \
   -group [get_clocks {pgpRxClk4x_2}] \
   -group [get_clocks -include_generated_clocks {sysClk}] 
   
set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk1x}] \
   -group [get_clocks {pgpTxClk2x}] \
   -group [get_clocks {pgpRxClk1x_3}] \
   -group [get_clocks {pgpRxClk2x_3}] \
   -group [get_clocks -include_generated_clocks {sysClk}] 

set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk4x}] \
   -group [get_clocks {pgpRxClk4x_3}] \
   -group [get_clocks -include_generated_clocks {sysClk}]     
