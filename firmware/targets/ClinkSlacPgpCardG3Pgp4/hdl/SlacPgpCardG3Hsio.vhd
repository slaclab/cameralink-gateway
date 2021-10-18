-------------------------------------------------------------------------------
-- File       : SlacPgpCardG3Hsio.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: SlacPgpCardG3Hsio File
-------------------------------------------------------------------------------
-- Fiber Mapping to Kcu1500Hsio:
--    QSFP[0][0] = PGP.Lane[0].VC[3:0]
--    QSFP[0][1] = PGP.Lane[1].VC[3:0]
--    QSFP[0][2] = PGP.Lane[2].VC[3:0]
--    QSFP[0][3] = PGP.Lane[3].VC[3:0]
--    QSFP[1][0] = LCLS-I  Timing Receiver
--    QSFP[1][1] = LCLS-II Timing Receiver
--    QSFP[1][2] = Unused QSFP Link
--    QSFP[1][3] = Unused QSFP Link
--           SFP = Unused QSFP Link
-------------------------------------------------------------------------------
-- This file is part of LCLS2 PGP Firmware Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of LCLS2 PGP Firmware Library', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library lcls_timing_core;
use lcls_timing_core.TimingPkg.all;

library l2si_core;
use l2si_core.L2SiPkg.all;

library lcls2_pgp_fw_lib;

library unisim;
use unisim.vcomponents.all;

entity SlacPgpCardG3Hsio is
   generic (
      TPD_G                          : time                        := 1 ns;
      ROGUE_SIM_EN_G                 : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G           : natural range 1024 to 49151 := 7000;
      DMA_AXIS_CONFIG_G              : AxiStreamConfigType;
      AXIL_CLK_FREQ_G                : real                        := 156.25E+6;  -- units of Hz
      AXI_BASE_ADDR_G                : slv(31 downto 0)            := x"0080_0000";
      NUM_PGP_LANES_G                : integer range 1 to 4        := 4;
      EN_LCLS_I_TIMING_G             : boolean                     := false;
      EN_LCLS_II_TIMING_G            : boolean                     := true;
      L1_CLK_IS_TIMING_TX_CLK_G      : boolean                     := false;
      TRIGGER_CLK_IS_TIMING_RX_CLK_G : boolean                     := false;
      EVENT_CLK_IS_TIMING_RX_CLK_G   : boolean                     := false);
   port (
      ------------------------
      --  Top Level Interfaces
      ------------------------
      -- AXI-Lite Interface
      axilClk               : in  sl;
      axilRst               : in  sl;
      axilReadMaster        : in  AxiLiteReadMasterType;
      axilReadSlave         : out AxiLiteReadSlaveType;
      axilWriteMaster       : in  AxiLiteWriteMasterType;
      axilWriteSlave        : out AxiLiteWriteSlaveType;
      -- PGP Streams (axilClk domain)
      pgpIbMasters          : in  AxiStreamMasterArray(NUM_PGP_LANES_G-1 downto 0);
      pgpIbSlaves           : out AxiStreamSlaveArray(NUM_PGP_LANES_G-1 downto 0);
      pgpObMasters          : out AxiStreamQuadMasterArray(NUM_PGP_LANES_G-1 downto 0);
      pgpObSlaves           : in  AxiStreamQuadSlaveArray(NUM_PGP_LANES_G-1 downto 0);
      -- Trigger Interface
      triggerClk            : in  sl;
      triggerRst            : in  sl;
      triggerData           : out TriggerEventDataArray(NUM_PGP_LANES_G-1 downto 0);
      -- L1 trigger feedback (optional)
      l1Clk                 : in  sl                                                 := '0';
      l1Rst                 : in  sl                                                 := '0';
      l1Feedbacks           : in  TriggerL1FeedbackArray(NUM_PGP_LANES_G-1 downto 0) := (others => TRIGGER_L1_FEEDBACK_INIT_C);
      l1Acks                : out slv(NUM_PGP_LANES_G-1 downto 0);
      -- Event streams
      eventClk              : in  sl;
      eventRst              : in  sl;
      eventTrigMsgMasters   : out AxiStreamMasterArray(NUM_PGP_LANES_G-1 downto 0);
      eventTrigMsgSlaves    : in  AxiStreamSlaveArray(NUM_PGP_LANES_G-1 downto 0);
      eventTrigMsgCtrl      : in  AxiStreamCtrlArray(NUM_PGP_LANES_G-1 downto 0);
      eventTimingMsgMasters : out AxiStreamMasterArray(NUM_PGP_LANES_G-1 downto 0);
      eventTimingMsgSlaves  : in  AxiStreamSlaveArray(NUM_PGP_LANES_G-1 downto 0);
      clearReadout          : out slv(NUM_PGP_LANES_G-1 downto 0);
      ---------------------
      --  Hardware Ports
      ---------------------
      -- PGP GT Serial Ports
      pgpRefClkP            : in  sl;
      pgpRefClkN            : in  sl;
      pgpRxP                : in  slv(7 downto 0);
      pgpRxN                : in  slv(7 downto 0);
      pgpTxP                : out slv(7 downto 0);
      pgpTxN                : out slv(7 downto 0);
      -- EVR GT Serial Ports
      evrRefClkP            : in  slv(1 downto 0);
      evrRefClkN            : in  slv(1 downto 0));
end SlacPgpCardG3Hsio;

architecture mapping of SlacPgpCardG3Hsio is

   constant NUM_AXIL_MASTERS_C : positive := 5;

   constant PGP_INDEX_C    : natural := 0;
   constant TIMING_INDEX_C : natural := 4;

   -- 22 Bits available
   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      PGP_INDEX_C+0   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0000_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"),
      PGP_INDEX_C+1   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0001_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"),
      PGP_INDEX_C+2   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0002_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"),
      PGP_INDEX_C+3   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0003_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"),
      TIMING_INDEX_C  => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0010_0000"),
         addrBits     => 20,
         connectivity => x"FFFF"));

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal pgpRefClk      : sl;
   signal qPllOutClk     : Slv2Array(3 downto 0) := (others => "00");
   signal qPllOutRefClk  : Slv2Array(3 downto 0) := (others => "00");
   signal qPllLock       : Slv2Array(3 downto 0) := (others => "00");
   signal qPllRefClkLost : Slv2Array(3 downto 0) := (others => "00");
   signal qpllRst        : Slv2Array(3 downto 0) := (others => "00");

   signal gtTxOutClk     : slv(3 downto 0) := (others => '0');
   signal gtTxPllRst     : slv(3 downto 0) := (others => '0');
   signal gtTxPllLock    : slv(3 downto 0) := (others => '0');
   signal pllOut         : slv(2 downto 0) := (others => '0');
   signal txPllClk       : slv(2 downto 0) := (others => '0');
   signal txPllRst       : slv(2 downto 0) := (others => '0');
   signal lockedStrobe   : slv(3 downto 0) := (others => '0');
   signal pllLock        : sl              := '0';
   signal clkFb          : sl              := '0';
   signal gtTxOutClkBufg : sl              := '0';

   signal qPllClkTiming    : slv(1 downto 0) := (others => '0');
   signal qPllRefClkTiming : slv(1 downto 0) := (others => '0');

   signal iTriggerData       : TriggerEventDataArray(NUM_PGP_LANES_G-1 downto 0);
   signal remoteTriggersComb : slv(NUM_PGP_LANES_G-1 downto 0) := (others => '0');
   signal remoteTriggers     : slv(NUM_PGP_LANES_G-1 downto 0) := (others => '0');
   signal triggerCodes       : slv8Array(NUM_PGP_LANES_G-1 downto 0);

begin

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   ------------------------
   -- GT Clocking
   ------------------------
   U_IBUFDS : IBUFDS_GTE2
      port map (
         I     => pgpRefClkP,
         IB    => pgpRefClkN,
         CEB   => '0',
         ODIV2 => open,
         O     => pgpRefClk);

   U_QPLL : entity surf.Pgp3Gtp7Qpll  -- Same IP core for both PGPv3 and PGPv4
      generic map (
         TPD_G         => TPD_G,
         EN_DRP_G      => false,
         REFCLK_FREQ_G => 250.0E+6,
         RATE_G        => "6.25Gbps")
      port map (
         -- Stable Clock and Reset
         stableClk      => axilClk,
         stableRst      => axilRst,
         -- QPLL Interface
         pgpRefClk      => pgpRefClk,
         qPllOutClk     => qPllOutClk,
         qPllOutRefClk  => qPllOutRefClk,
         qPllLock       => qPllLock,
         qpllRefClkLost => qpllRefClkLost,
         qpllRst        => qpllRst,
         -- AXI-Lite Interface
         axilClk        => axilClk,
         axilRst        => axilRst);

   --------------
   -- PGP Modules
   --------------
   GEN_LANE :
   for i in NUM_PGP_LANES_G-1 downto 0 generate

      U_Lane : entity work.Pgp4Lane
         generic map (
            TPD_G                => TPD_G,
            ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
            ROGUE_SIM_PORT_NUM_G => (ROGUE_SIM_PORT_NUM_G + i*34),
            DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
            AXIL_CLK_FREQ_G      => AXIL_CLK_FREQ_G,
            AXI_BASE_ADDR_G      => AXIL_CONFIG_C(i).baseAddr)
         port map (
            -- Trigger Interface
            trigger         => remoteTriggers(i),
            triggerCode     => triggerCodes(i),
            -- PGP Serial Ports
            pgpRxP          => pgpRxP(i+4),
            pgpRxN          => pgpRxN(i+4),
            pgpTxP          => pgpTxP(i+4),
            pgpTxN          => pgpTxN(i+4),
            -- QPLL Interface
            qPllOutClk      => qPllOutClk(i),
            qPllOutRefClk   => qPllOutRefClk(i),
            qPllLock        => qPllLock(i),
            qpllRefClkLost  => qpllRefClkLost(i),
            qpllRst         => qpllRst(i),
            -- TX PLL Interface
            gtTxOutClk      => gtTxOutClk(i),
            gtTxPllRst      => gtTxPllRst(i),
            txPllClk        => txPllClk,
            txPllRst        => txPllRst,
            gtTxPllLock     => gtTxPllLock(i),
            -- Streaming Interface (axilClk domain)
            pgpIbMaster     => pgpIbMasters(i),
            pgpIbSlave      => pgpIbSlaves(i),
            pgpObMasters    => pgpObMasters(i),
            pgpObSlaves     => pgpObSlaves(i),
            -- AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

      MASTER_LOCK : if (i = 0) generate
         gtTxPllLock(0) <= pllLock;
      end generate;

      SLAVE_LOCK : if (i /= 0) generate
         -- Prevent the gtTxPllRst of this lane disrupting the other lanes in the QUAD
         U_PwrUpRst : entity surf.PwrUpRst
            generic map (
               TPD_G      => TPD_G,
               DURATION_G => 125)
            port map (
               arst   => gtTxPllRst(i),
               clk    => axilClk,
               rstOut => lockedStrobe(i));
         -- Trick the GT state machine of lock transition
         gtTxPllLock(i) <= pllLock and not(lockedStrobe(i));
      end generate;

   end generate GEN_LANE;

   U_Bufg : BUFH
      port map (
         I => gtTxOutClk(0),
         O => gtTxOutClkBufg);

   U_TX_PLL : PLLE2_ADV
      generic map (
         BANDWIDTH      => "HIGH",
         CLKIN1_PERIOD  => 2.56,
         DIVCLK_DIVIDE  => 1,
         CLKFBOUT_MULT  => 4,
         CLKOUT0_DIVIDE => 16,
         CLKOUT1_DIVIDE => 4,
         CLKOUT2_DIVIDE => 8)
      port map (
         DCLK     => axilClk,
         DRDY     => open,
         DEN      => '0',
         DWE      => '0',
         DADDR    => (others => '0'),
         DI       => (others => '0'),
         DO       => open,
         PWRDWN   => '0',
         RST      => gtTxPllRst(0),
         CLKIN1   => gtTxOutClkBufg,
         CLKIN2   => '0',
         CLKINSEL => '1',
         CLKFBOUT => clkFb,
         CLKFBIN  => clkFb,
         LOCKED   => pllLock,
         CLKOUT0  => pllOut(0),
         CLKOUT1  => pllOut(1),
         CLKOUT2  => pllOut(2));

   U_txPllClk0 : BUFG
      port map (
         I => pllOut(0),
         O => txPllClk(0));

   U_txPllClk1 : BUFG
      port map (
         I => pllOut(1),
         O => txPllClk(1));

   U_txPllClk2 : BUFG
      port map (
         I => pllOut(2),
         O => txPllClk(2));

   GEN_RST : for i in 2 downto 0 generate
      U_RstSync : entity surf.RstSync
         generic map (
            TPD_G          => TPD_G,
            IN_POLARITY_G  => '0',
            OUT_POLARITY_G => '1')
         port map (
            clk      => txPllClk(i),
            asyncRst => pllLock,
            syncRst  => txPllRst(i));
   end generate;

   GEN_DUMMY : if (NUM_PGP_LANES_G < 4) generate
      U_QSFP1 : entity surf.Gtpe2ChannelDummy
         generic map (
            TPD_G        => TPD_G,
            SIMULATION_G => ROGUE_SIM_EN_G,
            EXT_QPLL_G   => true,
            WIDTH_G      => 4-NUM_PGP_LANES_G)
         port map (
            refClk           => axilClk,
            qPllOutClkExt    => qPllOutClk(NUM_PGP_LANES_G-1),
            qPllOutRefClkExt => qPllOutRefClk(NUM_PGP_LANES_G-1),
            gtRxP            => pgpRxP(7 downto NUM_PGP_LANES_G+4),
            gtRxN            => pgpRxN(7 downto NUM_PGP_LANES_G+4),
            gtTxP            => pgpTxP(7 downto NUM_PGP_LANES_G+4),
            gtTxN            => pgpTxN(7 downto NUM_PGP_LANES_G+4));
   end generate GEN_DUMMY;

   ------------------
   -- Timing Receiver
   ------------------
   U_TimingRx : entity work.TimingRx
      generic map (
         TPD_G               => TPD_G,
         SIMULATION_G        => ROGUE_SIM_EN_G,
         DMA_AXIS_CONFIG_G   => DMA_AXIS_CONFIG_G,
         AXIL_CLK_FREQ_G     => AXIL_CLK_FREQ_G,
         AXI_BASE_ADDR_G     => AXIL_CONFIG_C(TIMING_INDEX_C).baseAddr,
         NUM_DETECTORS_G     => NUM_PGP_LANES_G,
         EN_LCLS_I_TIMING_G  => EN_LCLS_I_TIMING_G,
         EN_LCLS_II_TIMING_G => EN_LCLS_II_TIMING_G)
      port map (
         triggerClk            => triggerClk,             -- [in]
         triggerRst            => triggerRst,             -- [in]
         triggerData           => iTriggerData,           -- [out]
         l1Clk                 => l1Clk,                  -- [in]
         l1Rst                 => l1Rst,                  -- [in]
         l1Feedbacks           => l1Feedbacks,            -- [in]
         l1Acks                => l1Acks,                 -- [out]
         eventClk              => eventClk,               -- [in]
         eventRst              => eventRst,               -- [in]
         eventTrigMsgMasters   => eventTrigMsgMasters,    -- [out]
         eventTrigMsgSlaves    => eventTrigMsgSlaves,     -- [in]
         eventTrigMsgCtrl      => eventTrigMsgCtrl,       -- [in]
         eventTimingMsgMasters => eventTimingMsgMasters,  -- [out]
         eventTimingMsgSlaves  => eventTimingMsgSlaves,   -- [in]
         clearReadout          => clearReadout,           -- [out]
         -- AXI-Lite Interface (axilClk domain)
         axilClk               => axilClk,
         axilRst               => axilRst,
         axilReadMaster        => axilReadMasters(TIMING_INDEX_C),
         axilReadSlave         => axilReadSlaves(TIMING_INDEX_C),
         axilWriteMaster       => axilWriteMasters(TIMING_INDEX_C),
         axilWriteSlave        => axilWriteSlaves(TIMING_INDEX_C),
         -- GT Serial Ports
         refClkP               => evrRefClkP,
         refClkN               => evrRefClkN,
         qPllClkTiming         => qPllClkTiming,
         qPllRefClkTiming      => qPllRefClkTiming,
         timingRxP             => pgpRxP(1 downto 0),
         timingRxN             => pgpRxN(1 downto 0),
         timingTxP             => pgpTxP(1 downto 0),
         timingTxN             => pgpTxN(1 downto 0));

   --------------------------------
   -- Feed triggers directly to PGP
   --------------------------------
   TRIGGER_GEN : for i in NUM_PGP_LANES_G-1 downto 0 generate
      remoteTriggersComb(i) <= iTriggerData(i).valid and iTriggerData(i).l0Accept;
      triggerCodes(i)       <= "000" & iTriggerData(i).l0Tag;
   end generate TRIGGER_GEN;
   U_RegisterVector_1 : entity surf.RegisterVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => NUM_PGP_LANES_G)
      port map (
         clk   => triggerClk,           -- [in]
         sig_i => remoteTriggersComb,   -- [in]
         reg_o => remoteTriggers);      -- [out]

   triggerData <= iTriggerData;

   --------------------
   -- Unused QSFP Links
   --------------------
   U_QSFP1 : entity surf.Gtpe2ChannelDummy
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => ROGUE_SIM_EN_G,
         EXT_QPLL_G   => true,
         WIDTH_G      => 2)
      port map (
         refClk           => axilClk,
         qPllOutClkExt    => qPllClkTiming,
         qPllOutRefClkExt => qPllRefClkTiming,
         gtRxP            => pgpRxP(3 downto 2),
         gtRxN            => pgpRxN(3 downto 2),
         gtTxP            => pgpTxP(3 downto 2),
         gtTxN            => pgpTxN(3 downto 2));

end mapping;
