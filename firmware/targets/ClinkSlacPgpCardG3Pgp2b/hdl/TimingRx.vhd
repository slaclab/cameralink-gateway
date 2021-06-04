-------------------------------------------------------------------------------
-- File       : TimingRx.vhd
-- Company    : SLAC National Accelerator Laboratory
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library unisim;
use unisim.vcomponents.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library lcls_timing_core;
use lcls_timing_core.TimingPkg.all;

library l2si_core;
use l2si_core.L2SiPkg.all;

library lcls2_pgp_fw_lib;

entity TimingRx is
   generic (
      TPD_G               : time    := 1 ns;
      SIMULATION_G        : boolean := false;
      USE_GT_REFCLK_G     : boolean := false;  -- False: userClk25/userRst25, True: refClkP/N
      AXIL_CLK_FREQ_G     : real    := 156.25E+6;  -- units of Hz
      DMA_AXIS_CONFIG_G   : AxiStreamConfigType;
      AXI_BASE_ADDR_G     : slv(31 downto 0);
      NUM_DETECTORS_G     : integer range 1 to 4;
      EN_LCLS_I_TIMING_G  : boolean := false;
      EN_LCLS_II_TIMING_G : boolean := true);
   port (
      -- Reference Clock and Reset
      userClk25   : in  sl := '0';      -- USE_GT_REFCLK_G = FALSE
      userRst25   : in  sl := '1';      -- USE_GT_REFCLK_G = FALSE
      -- Trigger Interface
      triggerClk  : in  sl;
      triggerRst  : in  sl;
      triggerData : out TriggerEventDataArray(NUM_DETECTORS_G-1 downto 0);

      -- L1 trigger feedback (optional)
      l1Clk                 : in  sl                                                 := '0';
      l1Rst                 : in  sl                                                 := '0';
      l1Feedbacks           : in  TriggerL1FeedbackArray(NUM_DETECTORS_G-1 downto 0) := (others => TRIGGER_L1_FEEDBACK_INIT_C);
      l1Acks                : out slv(NUM_DETECTORS_G-1 downto 0);
      -- Event streams
      eventClk              : in  sl;
      eventRst              : in  sl;
      eventTrigMsgMasters   : out AxiStreamMasterArray(NUM_DETECTORS_G-1 downto 0);
      eventTrigMsgSlaves    : in  AxiStreamSlaveArray(NUM_DETECTORS_G-1 downto 0);
      eventTrigMsgCtrl      : in  AxiStreamCtrlArray(NUM_DETECTORS_G-1 downto 0);
      eventTimingMsgMasters : out AxiStreamMasterArray(NUM_DETECTORS_G-1 downto 0);
      eventTimingMsgSlaves  : in  AxiStreamSlaveArray(NUM_DETECTORS_G-1 downto 0);
      clearReadout          : out slv(NUM_DETECTORS_G-1 downto 0)                    := (others => '0');
      -- AXI-Lite Interface
      axilClk               : in  sl;
      axilRst               : in  sl;
      axilReadMaster        : in  AxiLiteReadMasterType;
      axilReadSlave         : out AxiLiteReadSlaveType;
      axilWriteMaster       : in  AxiLiteWriteMasterType;
      axilWriteSlave        : out AxiLiteWriteSlaveType;
      -- GT Serial Ports
      refClkP               : in  slv(1 downto 0);
      refClkN               : in  slv(1 downto 0);
      qPllClkTiming         : out slv(1 downto 0);
      qPllRefClkTiming      : out slv(1 downto 0);
      timingRxP             : in  slv(1 downto 0);
      timingRxN             : in  slv(1 downto 0);
      timingTxP             : out slv(1 downto 0);
      timingTxN             : out slv(1 downto 0));
end TimingRx;

architecture mapping of TimingRx is

   constant NUM_AXIL_MASTERS_C : positive := 6;

   constant RX_PHY0_INDEX_C  : natural := 0;
   constant RX_PHY1_INDEX_C  : natural := 1;
   constant MON_INDEX_C      : natural := 2;
   constant TIMING_INDEX_C   : natural := 3;
   constant XPM_MINI_INDEX_C : natural := 4;
   constant TEM_INDEX_C      : natural := 5;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      RX_PHY0_INDEX_C  => (
         baseAddr      => (AXI_BASE_ADDR_G+x"0000_0000"),
         addrBits      => 16,
         connectivity  => x"FFFF"),
      RX_PHY1_INDEX_C  => (
         baseAddr      => (AXI_BASE_ADDR_G+x"0001_0000"),
         addrBits      => 16,
         connectivity  => x"FFFF"),
      MON_INDEX_C      => (
         baseAddr      => (AXI_BASE_ADDR_G+x"0002_0000"),
         addrBits      => 16,
         connectivity  => x"FFFF"),
      XPM_MINI_INDEX_C => (
         baseAddr      => (AXI_BASE_ADDR_G+X"0003_0000"),
         addrBits      => 16,
         connectivity  => X"FFFF"),
      TEM_INDEX_C      => (
         baseAddr      => (AXI_BASE_ADDR_G+x"0004_0000"),
         addrBits      => 16,
         connectivity  => x"FFFF"),
      TIMING_INDEX_C   => (
         baseAddr      => (AXI_BASE_ADDR_G+x"0008_0000"),
         addrBits      => 18,
         connectivity  => x"FFFF"));

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)   := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal mmcmRst      : sl;
   signal gtediv2      : slv(1 downto 0);
   signal refClk       : slv(1 downto 0);
   signal refRst       : slv(1 downto 0);
   signal mmcmLocked   : slv(1 downto 0);
   signal timingClkSel : sl;
   signal useMiniTpg   : sl;
   signal loopback     : slv(2 downto 0);

   signal rxUserRst       : sl;
   signal gtRxOutClk      : slv(1 downto 0);
   signal gtRxClk         : slv(1 downto 0);
   signal timingRxClk     : sl;
   signal timingRxRst     : sl;
   signal timingRxRstTmp  : sl;
   signal gtRxData        : Slv16Array(1 downto 0);
   signal rxData          : slv(15 downto 0);
   signal gtRxDataK       : Slv2Array(1 downto 0);
   signal rxDataK         : slv(1 downto 0);
   signal gtRxDispErr     : Slv2Array(1 downto 0);
   signal rxDispErr       : slv(1 downto 0);
   signal gtRxDecErr      : Slv2Array(1 downto 0);
   signal rxDecErr        : slv(1 downto 0);
   signal gtRxStatus      : TimingPhyStatusArray(1 downto 0);
   signal rxStatus        : TimingPhyStatusType;
   signal timingRxControl : TimingPhyControlType;
   signal gtRxControl     : TimingPhyControlType;

   signal txUserRst     : sl;
   signal gtTxOutClk    : slv(1 downto 0);
   signal gtTxClk       : slv(1 downto 0);
   signal timingTxClk   : sl;
   signal timingTxRst   : sl;
--   signal txStatus   : TimingPhyStatusType := TIMING_PHY_STATUS_FORCE_C;
   signal gtTxStatus    : TimingPhyStatusArray(1 downto 0);
   signal gtTxControl   : TimingPhyControlType;
   signal txPhyReset    : sl;
   signal txPhyPllReset : sl;

   signal tpgMiniStreamTimingPhy : TimingPhyType;
   signal xpmMiniTimingPhy       : TimingPhyType;
   signal appTimingBus           : TimingBusType;
   signal appTimingMode          : sl;

   -----------------------------------------------
   -- Event Header Cache signals
   -----------------------------------------------
   signal temTimingTxPhy : TimingPhyType;

   signal eventTimingMessagesValid : slv(NUM_DETECTORS_G-1 downto 0);
   signal eventTimingMessages      : TimingMessageArray(NUM_DETECTORS_G-1 downto 0);
   signal eventTimingMessagesRd    : slv(NUM_DETECTORS_G-1 downto 0);

   signal qPllRefClk     : slv(1 downto 0);
   signal qPllClk        : slv(1 downto 0);
   signal qPllLock       : slv(1 downto 0);
   signal qPllRefClkLost : slv(1 downto 0);
   signal qPllLockDetClk : slv(1 downto 0);
   signal qPllReset      : Slv2Array(1 downto 0);

begin

   timingTxRst    <= txUserRst;
   timingRxRstTmp <= rxUserRst or not rxStatus.resetDone;

   U_RstSync_1 : entity surf.RstSync
      generic map (
         TPD_G => TPD_G)
      port map (
         clk      => timingRxClk,       -- [in]
         asyncRst => timingRxRstTmp,    -- [in]
         syncRst  => timingRxRst);      -- [out]

   GEN_GT_VEC :
   for i in 1 downto 0 generate

      U_IBUFDS : IBUFDS_GTE2
         port map (
            I     => refClkP(i),
            IB    => refClkN(i),
            CEB   => '0',
            ODIV2 => gtediv2(i),
            O     => open);

      U_BUFG : BUFG
         port map (
            I => gtediv2(i),
            O => refClk(i));

      U_RstSync : entity surf.RstSync
         generic map (
            TPD_G => TPD_G)
         port map (
            clk      => refClk(i),
            asyncRst => mmcmRst,
            syncRst  => refRst(i));

      mmcmLocked(i) <= not(refRst(i));

   end generate GEN_GT_VEC;

   U_QPLL : entity surf.Gtp7QuadPll
      generic map (
         TPD_G                => TPD_G,
         -- PLL0 Configured for 2.38 Gbps
         PLL0_REFCLK_SEL_G    => "111",
         PLL0_FBDIV_IN_G      => 4,
         PLL0_FBDIV_45_IN_G   => 5,
         PLL0_REFCLK_DIV_IN_G => 1,
         -- PLL1 Configured for 3.71428571 Gbps
         PLL1_REFCLK_SEL_G    => "111",
         PLL1_FBDIV_IN_G      => 2,
         PLL1_FBDIV_45_IN_G   => 5,
         PLL1_REFCLK_DIV_IN_G => 1)
      port map (
         qPllRefClk     => refClk,
         qPllOutClk     => qPllClk,
         qPllOutRefClk  => qPllRefClk,
         qPllLock       => qPllLock,
         qPllLockDetClk => qPllLockDetClk,
         qPllRefClkLost => qPllRefClkLost,
         qPllReset(0)   => qPllReset(0)(0),
         qPllReset(1)   => qPllReset(1)(1),
         -- AXI Lite interface
         axilClk        => axilClk,
         axilRst        => axilRst);

   qPllLockDetClk   <= (others => axilClk);
   qPllClkTiming    <= qPllClk;
   qPllRefClkTiming <= qPllRefClk;

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

   -------------
   -- GTP Module
   -------------
   GEN_VEC : for i in 1 downto 0 generate

      U_RXCLK : BUFGMUX
         generic map (
            CLK_SEL_TYPE => "ASYNC")    -- ASYNC, SYNC
         port map (
            O  => gtRxClk(i),           -- 1-bit output: Clock output
            I0 => gtRxOutClk(i),        -- 1-bit input: Clock input (S=0)
            I1 => refClk(i),            -- 1-bit input: Clock input (S=1)
            S  => useMiniTpg);          -- 1-bit input: Clock select

      U_TXCLK : BUFGMUX
         generic map (
            CLK_SEL_TYPE => "ASYNC")    -- ASYNC, SYNC
         port map (
            O  => gtTxClk(i),           -- 1-bit output: Clock output
            I0 => gtTxOutClk(i),        -- 1-bit input: Clock input (S=0)
            I1 => refClk(i),            -- 1-bit input: Clock input (S=1)
            S  => useMiniTpg);          -- 1-bit input: Clock select

      REAL_PCIE : if (not SIMULATION_G) generate

         U_GTP : entity lcls_timing_core.TimingGtCoreWrapper
            generic map (
               TPD_G       => TPD_G,
               PLL_G       => ite(i = 0, "PLL0", "PLL1"),
               GT_CONFIG_G => ite(i = 0, false, true))  -- V1 = false, V2 = true
            port map (
               -- AXI-Lite Port
               axilClk          => axilClk,
               axilRst          => axilRst,
               axilReadMaster   => axilReadMasters(RX_PHY0_INDEX_C+i),
               axilReadSlave    => axilReadSlaves(RX_PHY0_INDEX_C+i),
               axilWriteMaster  => axilWriteMasters(RX_PHY0_INDEX_C+i),
               axilWriteSlave   => axilWriteSlaves(RX_PHY0_INDEX_C+i),
               -- QPLL Ports
               gtQPllOutRefClk  => qPllRefClk,
               gtQPllOutClk     => qPllClk,
               gtQPllLock       => qPllLock,
               gtQPllRefClkLost => qPllRefClkLost,
               gtQPllReset      => qPllReset(i),
               -- GTH FPGA IO
               gtRxP            => timingRxP(i),
               gtRxN            => timingRxN(i),
               gtTxP            => timingTxP(i),
               gtTxN            => timingTxN(i),
               stableClk        => axilClk,
               stableRst        => axilRst,
               -- Rx ports
               rxControl        => gtRxControl,
               rxStatus         => gtRxStatus(i),
               rxData           => gtRxData(i),
               rxDataK          => gtRxDataK(i),
               rxDispErr        => gtRxDispErr(i),
               rxDecErr         => gtRxDecErr(i),
               rxOutClk         => gtRxOutClk(i),
               -- Tx Ports
               txControl        => gtTxControl,  --temTimingTxPhy.control,
               txStatus         => gtTxStatus(i),
               txData           => temTimingTxPhy.data,
               txDataK          => temTimingTxPhy.dataK,
               txOutClk         => gtTxOutClk(i),
               -- Misc.
               loopback         => loopback);
      end generate;


      SIM_PCIE : if (SIMULATION_G) generate

         axilReadSlaves(RX_PHY0_INDEX_C+i)  <= AXI_LITE_READ_SLAVE_EMPTY_OK_C;
         axilWriteSlaves(RX_PHY0_INDEX_C+i) <= AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

         gtRxOutClk(i) <= refClk(i);
         gtTxOutClk(i) <= refClk(i);

         gtTxStatus(i)  <= TIMING_PHY_STATUS_FORCE_C;
         gtRxStatus(i)  <= TIMING_PHY_STATUS_FORCE_C;
         gtRxData(i)    <= (others => '0');  --temTimingTxPhy.data;
         gtRxDataK(i)   <= (others => '0');  --temTimingTxPhy.dataK;
         gtRxDispErr(i) <= "00";
         gtRxDecErr(i)  <= "00";

      end generate;
   end generate GEN_VEC;

   process(timingRxClk)
   begin
      -- Register to help meet timing
      if rising_edge(timingRxClk) then
         if (useMiniTpg = '1') then
            if (timingClkSel = '1' and EN_LCLS_II_TIMING_G) then
               rxStatus  <= TIMING_PHY_STATUS_FORCE_C after TPD_G;
               rxData    <= xpmMiniTimingPhy.data     after TPD_G;
               rxDataK   <= xpmMiniTimingPhy.dataK    after TPD_G;
               rxDispErr <= "00"                      after TPD_G;
               rxDecErr  <= "00"                      after TPD_G;
            elsif (timingClkSel = '0' and EN_LCLS_I_TIMING_G) then
               rxStatus  <= TIMING_PHY_STATUS_FORCE_C    after TPD_G;
               rxData    <= tpgMiniStreamTimingPhy.data  after TPD_G;
               rxDataK   <= tpgMiniStreamTimingPhy.dataK after TPD_G;
               rxDispErr <= "00"                         after TPD_G;
               rxDecErr  <= "00"                         after TPD_G;
            end if;
         elsif (timingClkSel = '1') then
--            txStatus  <= gtTxStatus(1)  after TPD_G;
            rxStatus  <= gtRxStatus(1)  after TPD_G;
            rxData    <= gtRxData(1)    after TPD_G;
            rxDataK   <= gtRxDataK(1)   after TPD_G;
            rxDispErr <= gtRxDispErr(1) after TPD_G;
            rxDecErr  <= gtRxDecErr(1)  after TPD_G;
         else
--            txStatus  <= gtTxStatus(0)  after TPD_G;
            rxStatus  <= gtRxStatus(0)  after TPD_G;
            rxData    <= gtRxData(0)    after TPD_G;
            rxDataK   <= gtRxDataK(0)   after TPD_G;
            rxDispErr <= gtRxDispErr(0) after TPD_G;
            rxDecErr  <= gtRxDecErr(0)  after TPD_G;
         end if;
      end if;
   end process;

   U_RXCLK : BUFGMUX
      generic map (
         CLK_SEL_TYPE => "ASYNC")       -- ASYNC, SYNC
      port map (
         O  => timingRxClk,             -- 1-bit output: Clock output
         I0 => gtRxClk(0),              -- 1-bit input: Clock input (S=0)
         I1 => gtRxClk(1),              -- 1-bit input: Clock input (S=1)
         S  => timingClkSel);           -- 1-bit input: Clock select

   -- NEED to do the same thing as RX!!!!
   -- NEED TXOUTCLKs switched in here
   U_TXCLK : BUFGMUX
      generic map (
         CLK_SEL_TYPE => "ASYNC")       -- ASYNC, SYNC
      port map (
         O  => timingTxClk,             -- 1-bit output: Clock output
         I0 => gtTxClk(0),              -- 1-bit input: Clock input (S=0)
         I1 => gtTxClk(1),              -- 1-bit input: Clock input (S=1)
         S  => timingClkSel);           -- 1-bit input: Clock select

   -----------------------
   -- Insert user RX reset
   -----------------------
   gtRxControl.reset       <= timingRxControl.reset or rxUserRst;
   gtRxControl.inhibit     <= timingRxControl.inhibit;
   gtRxControl.polarity    <= timingRxControl.polarity;
   gtRxControl.bufferByRst <= timingRxControl.bufferByRst;
   gtRxControl.pllReset    <= timingRxControl.pllReset or rxUserRst;

   gtTxControl.reset       <= temTimingTxPhy.control.reset or txPhyReset;
   gtTxControl.pllReset    <= temTimingTxPhy.control.pllReset or txPhyPllReset;
   gtTxControl.inhibit     <= temTimingTxPhy.control.inhibit;
   gtTxControl.polarity    <= temTimingTxPhy.control.polarity;
   gtTxControl.bufferByRst <= temTimingTxPhy.control.bufferByRst;

   --------------
   -- Timing Core
   --------------
   U_TimingCore : entity lcls_timing_core.TimingCore
      generic map (
         TPD_G             => TPD_G,
         DEFAULT_CLK_SEL_G => toSl(EN_LCLS_II_TIMING_G),  -- '0': default LCLS-I, '1': default LCLS-II
         TPGEN_G           => false,
         AXIL_RINGB_G      => false,
         ASYNC_G           => true,
         AXIL_BASE_ADDR_G  => AXIL_CONFIG_C(TIMING_INDEX_C).baseAddr)
      port map (
         -- GT Interface
         gtTxUsrClk       => timingTxClk,
         gtTxUsrRst       => timingTxRst,
         gtRxRecClk       => timingRxClk,
         gtRxData         => rxData,
         gtRxDataK        => rxDataK,
         gtRxDispErr      => rxDispErr,
         gtRxDecErr       => rxDecErr,
         gtRxControl      => timingRxControl,
         gtRxStatus       => rxStatus,
         tpgMiniTimingPhy => open,
         timingClkSel     => timingClkSel,
         -- Decoded timing message interface
         appTimingClk     => timingRxClk,
         appTimingRst     => timingRxRst,
         appTimingMode    => appTimingMode,
         appTimingBus     => appTimingBus,
         -- AXI Lite interface
         axilClk          => axilClk,
         axilRst          => axilRst,
         axilReadMaster   => axilReadMasters(TIMING_INDEX_C),
         axilReadSlave    => axilReadSlaves(TIMING_INDEX_C),
         axilWriteMaster  => axilWriteMasters(TIMING_INDEX_C),
         axilWriteSlave   => axilWriteSlaves(TIMING_INDEX_C));

   ---------------------
   -- XPM Mini Wrapper
   -- Simulates a timing/xpm stream
   ---------------------
   U_XpmMiniWrapper_1 : entity l2si_core.XpmMiniWrapper
      generic map (
         TPD_G           => TPD_G,
         NUM_DS_LINKS_G  => 1,
         AXIL_BASEADDR_G => AXIL_CONFIG_C(XPM_MINI_INDEX_C).baseAddr)
      port map (
         timingClk => timingRxClk,       -- [in]
         timingRst => timingRxRst,       -- [in]
         dsTx(0)   => xpmMiniTimingPhy,  -- [out]

         dsRxClk(0)     => timingTxClk,           -- [in]
         dsRxRst(0)     => timingTxRst,           -- [in]
         dsRx(0).data   => temTimingTxPhy.data,   -- [in]
         dsRx(0).dataK  => temTimingTxPhy.dataK,  -- [in]
         dsRx(0).decErr => (others => '0'),       -- [in]
         dsRx(0).dspErr => (others => '0'),       -- [in]

         tpgMiniStream => tpgMiniStreamTimingPhy,  -- [out]

         axilClk         => axilClk,                             -- [in]
         axilRst         => axilRst,                             -- [in]
         axilReadMaster  => axilReadMasters(XPM_MINI_INDEX_C),   -- [in]
         axilReadSlave   => axilReadSlaves(XPM_MINI_INDEX_C),    -- [out]
         axilWriteMaster => axilWriteMasters(XPM_MINI_INDEX_C),  -- [in]
         axilWriteSlave  => axilWriteSlaves(XPM_MINI_INDEX_C));  -- [out]

   ---------------------
   -- Timing PHY Monitor
   -- This is mostly unused now. Trigger monitoring is done in the TriggerEventManager
   -- Still need the useMiniTpg register
   ---------------------
   U_Monitor : entity lcls2_pgp_fw_lib.TimingPhyMonitor
      generic map (
         TPD_G           => TPD_G,
         SIMULATION_G    => SIMULATION_G,
         AXIL_CLK_FREQ_G => AXIL_CLK_FREQ_G)
      port map (
         rxUserRst       => rxUserRst,
         txUserRst       => txUserRst,
         txPhyReset      => txPhyReset,
         txPhyPllReset   => txPhyPllReset,
         useMiniTpg      => useMiniTpg,
         mmcmRst         => mmcmRst,
         loopback        => loopback,
         remTrig         => (others => '0'),  --remTrig,
         remTrigDrop     => (others => '0'),  --remTrigDrop,
         locTrig         => (others => '0'),  --locTrig,
         locTrigDrop     => (others => '0'),  --locTrigDrop,
         mmcmLocked      => mmcmLocked,
         refClk          => refClk,
         refRst          => refRst,
         txClk           => timingTxClk,
         txRst           => timingTxRst,
         rxClk           => timingRxClk,
         rxRst           => timingRxRst,
         -- AXI Lite interface
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(MON_INDEX_C),
         axilReadSlave   => axilReadSlaves(MON_INDEX_C),
         axilWriteMaster => axilWriteMasters(MON_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(MON_INDEX_C));


   ---------------------------------------------------------------
   -- Decode events and buffer them for the application
   ---------------------------------------------------------------
   U_TriggerEventManager_1 : entity l2si_core.TriggerEventManager
      generic map (
         TPD_G                          => TPD_G,
         EN_LCLS_I_TIMING_G             => EN_LCLS_I_TIMING_G,
         EN_LCLS_II_TIMING_G            => EN_LCLS_II_TIMING_G,
         NUM_DETECTORS_G                => NUM_DETECTORS_G,
         AXIL_BASE_ADDR_G               => AXIL_CONFIG_C(TEM_INDEX_C).baseAddr,
         EVENT_AXIS_CONFIG_G            => DMA_AXIS_CONFIG_G,
         L1_CLK_IS_TIMING_TX_CLK_G      => false,
         TRIGGER_CLK_IS_TIMING_RX_CLK_G => false,
         EVENT_CLK_IS_TIMING_RX_CLK_G   => false)
      port map (
         timingRxClk              => timingRxClk,                    -- [in]
         timingRxRst              => timingRxRst,                    -- [in]
         timingBus                => appTimingBus,                   -- [in]
         timingMode               => appTimingMode,                  -- [in]
         timingTxClk              => timingTxClk,                    -- [in]
         timingTxRst              => timingTxRst,                    -- [in]
         timingTxPhy              => temTimingTxPhy,                 -- [out]
         triggerClk               => triggerClk,                     -- [in]
         triggerRst               => triggerRst,                     -- [in]
         triggerData              => triggerData,                    -- [out]
         clearReadout             => clearReadout,                   -- [out]
         l1Clk                    => l1Clk,                          -- [in]
         l1Rst                    => l1Rst,                          -- [in]
         l1Feedbacks              => l1Feedbacks,                    -- [in]
         l1Acks                   => l1Acks,                         -- [out]
         eventClk                 => eventClk,                       -- [in]
         eventRst                 => eventRst,                       -- [in]
         eventTimingMessagesValid => eventTimingMessagesValid,       -- [out]
         eventTimingMessages      => eventTimingMessages,            -- [out]
         eventTimingMessagesRd    => eventTimingMessagesRd,          -- [in]
         eventAxisMasters         => eventTrigMsgMasters,            -- [out]
         eventAxisSlaves          => eventTrigMsgSlaves,             -- [in]
         eventAxisCtrl            => eventTrigMsgCtrl,               -- [in]
         axilClk                  => axilClk,                        -- [in]
         axilRst                  => axilRst,                        -- [in]
         axilReadMaster           => axilReadMasters(TEM_INDEX_C),   -- [in]
         axilReadSlave            => axilReadSlaves(TEM_INDEX_C),    -- [out]
         axilWriteMaster          => axilWriteMasters(TEM_INDEX_C),  -- [in]
         axilWriteSlave           => axilWriteSlaves(TEM_INDEX_C));  -- [out]

   U_EventTimingMessage : entity l2si_core.EventTimingMessage
      generic map (
         TPD_G               => TPD_G,
         NUM_DETECTORS_G     => NUM_DETECTORS_G,
         EVENT_AXIS_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         -- Clock and Reset
         eventClk                 => eventClk,                  -- [in]
         eventRst                 => eventRst,                  -- [in]
         -- Input Streams
         eventTimingMessagesValid => eventTimingMessagesValid,  -- [in]
         eventTimingMessages      => eventTimingMessages,       -- [in]
         eventTimingMessagesRd    => eventTimingMessagesRd,     -- [out]
         -- Output Streams
         eventTimingMsgMasters    => eventTimingMsgMasters,     -- [out]
         eventTimingMsgSlaves     => eventTimingMsgSlaves);     -- [in]

end mapping;
