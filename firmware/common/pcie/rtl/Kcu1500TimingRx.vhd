-------------------------------------------------------------------------------
-- File       : Kcu1500TimingRx.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- This file is part of 'Camera link gateway'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Camera link gateway', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.TimingPkg.all;
use work.TDetPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu1500TimingRx is
   generic (
      TPD_G             : time := 1 ns;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      AXI_BASE_ADDR_G   : slv(31 downto 0));
   port (
      -- Trigger Interface
      trigger         : out slv(3 downto 0);
      -- Readout Interface (axilClk domain)
      tdetTiming      : in  TDetTimingArray(3 downto 0) := (others => TDET_TIMING_INIT_C);
      tdetStatus      : out TDetStatusArray(3 downto 0);
      -- Event stream (axilClk domain)
      tdetEventMaster : out AxiStreamMasterArray(3 downto 0);
      tdetEventSlave  : in  AxiStreamSlaveArray(3 downto 0);
      -- Transition stream (axilClk domain)
      tdetTransMaster : out AxiStreamMasterArray(3 downto 0);
      tdetTransSlave  : in  AxiStreamSlaveArray(3 downto 0);
      -- Reference Clock and Reset
      userClk25       : in  sl;
      userRst25       : in  sl;
      -- AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- GT Serial Ports
      timingRxP       : in  slv(1 downto 0);
      timingRxN       : in  slv(1 downto 0);
      timingTxP       : out slv(1 downto 0);
      timingTxN       : out slv(1 downto 0));
end Kcu1500TimingRx;

architecture mapping of Kcu1500TimingRx is

   constant NUM_AXIL_MASTERS_C : positive := 4;

   constant RX_PHY0_INDEX_C : natural := 0;
   constant RX_PHY1_INDEX_C : natural := 1;
   constant TIMING_INDEX_C  : natural := 2;
   constant MON_INDEX_C     : natural := 3;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXI_BASE_ADDR_G, 20, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal mmcmRst        : sl;
   signal refClk         : slv(1 downto 0);
   signal refRst         : slv(1 downto 0);
   signal mmcmLocked     : slv(1 downto 0);
   signal timingClockSel : sl;
   signal loopback       : slv(2 downto 0);

   signal rxUserRst   : sl;
   signal gtRxClk     : slv(1 downto 0);
   signal rxClk       : sl;
   signal rxRst       : sl;
   signal rxReset     : sl;
   signal gtRxData    : Slv16Array(1 downto 0);
   signal rxData      : slv(15 downto 0);
   signal gtRxDataK   : Slv2Array(1 downto 0);
   signal rxDataK     : slv(1 downto 0);
   signal gtRxDispErr : Slv2Array(1 downto 0);
   signal rxDispErr   : slv(1 downto 0);
   signal gtRxDecErr  : Slv2Array(1 downto 0);
   signal rxDecErr    : slv(1 downto 0);
   signal gtRxStatus  : TimingPhyStatusArray(1 downto 0);
   signal rxStatus    : TimingPhyStatusType;
   signal rxCtrl      : TimingPhyControlType;
   signal rxControl   : TimingPhyControlType;

   signal txUserRst    : sl;
   signal gtTxClk      : slv(1 downto 0);
   signal txClk        : sl;
   signal txRst        : sl;
   signal txData       : slv(15 downto 0);
   signal txDataK      : slv(1 downto 0);
   signal txDiffCtrl   : slv(3 downto 0);
   signal txPreCursor  : slv(4 downto 0);
   signal txPostCursor : slv(4 downto 0);
   signal gtTxStatus   : TimingPhyStatusArray(1 downto 0);
   signal txStatus     : TimingPhyStatusType := TIMING_PHY_STATUS_INIT_C;
   signal timingPhy    : TimingPhyType;
   signal timingBus    : TimingBusType;

   signal trigBus : TDetTrigArray(3 downto 0);

begin

   txRst   <= txUserRst;
   rxReset <= rxUserRst or not(rxStatus.resetDone);
   rxRst   <= rxUserRst;

   --------------------------------------------------
   -- Send the trigger to the PGP's sideband opCodeEn 
   --------------------------------------------------
   GEN_LANE : for i in 3 downto 0 generate
      trigger(i) <= trigBus(i).valid;
   end generate GEN_LANE;

   -------------------------   
   -- Reference LCLS-I Clock
   -------------------------   
   U_238MHz : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 40.0,    -- 25 MHz
         DIVCLK_DIVIDE_G    => 1,       -- 25 MHz = 25MHz/1
         CLKFBOUT_MULT_F_G  => 29.750,  -- 743.75 MHz = 25 MHz x 29.75
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 238 MHz = 743.75 MHz/3.125
      port map(
         -- Clock Input
         clkIn     => userClk25,
         rstIn     => mmcmRst,
         -- Clock Outputs
         clkOut(0) => refClk(0),
         -- Reset Outputs
         rstOut(0) => refRst(0),
         -- Locked Status
         locked    => mmcmLocked(0));

   -------------------------   
   -- Reference LCLS-I Clock
   -------------------------           
   U_371MHz : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "HIGH",
         CLKIN_PERIOD_G     => 40.0,    -- 25 MHz
         DIVCLK_DIVIDE_G    => 1,       -- 25 MHz = 25MHz/1
         CLKFBOUT_MULT_F_G  => 52.000,  -- 1.3 GHz = 25 MHz x 52
         CLKOUT0_DIVIDE_F_G => 3.500)   -- 371.429 MHz = 1.3 GHz/3.5
      port map(
         -- Clock Input
         clkIn     => userClk25,
         rstIn     => mmcmRst,
         -- Clock Outputs
         clkOut(0) => refClk(1),
         -- Reset Outputs
         rstOut(0) => refRst(1),
         -- Locked Status
         locked    => mmcmLocked(1));

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_XBAR : entity work.AxiLiteCrossbar
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
   -- GTH Module
   -------------
   GEN_VEC : for i in 1 downto 0 generate

      U_GTH : entity work.TimingGtCoreWrapper
         generic map (
            TPD_G            => TPD_G,
            EXTREF_G         => false,
            AXIL_BASE_ADDR_G => AXIL_CONFIG_C(RX_PHY0_INDEX_C+i).baseAddr,
            ADDR_BITS_G      => 12,
            GTH_DRP_OFFSET_G => x"00001000")
         port map (
            -- AXI-Lite Port
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(RX_PHY0_INDEX_C+i),
            axilReadSlave   => axilReadSlaves(RX_PHY0_INDEX_C+i),
            axilWriteMaster => axilWriteMasters(RX_PHY0_INDEX_C+i),
            axilWriteSlave  => axilWriteSlaves(RX_PHY0_INDEX_C+i),
            stableClk       => axilClk,
            stableRst       => axilRst,
            -- GTH FPGA IO
            gtRefClk        => refClk(i),
            gtRefClkDiv2    => refClk(i),
            gtRxP           => timingRxP(i),
            gtRxN           => timingRxN(i),
            gtTxP           => timingTxP(i),
            gtTxN           => timingTxN(i),
            -- Rx ports
            rxControl       => rxControl,
            rxStatus        => gtRxStatus(i),
            rxUsrClkActive  => mmcmLocked(i),
            rxUsrClk        => gtRxClk(i),
            rxData          => gtRxData(i),
            rxDataK         => gtRxDataK(i),
            rxDispErr       => gtRxDispErr(i),
            rxDecErr        => gtRxDecErr(i),
            rxOutClk        => gtRxClk(i),
            -- Tx Ports
            txControl       => timingPhy.control,
            txStatus        => gtTxStatus(i),
            txUsrClk        => gtTxClk(i),
            txUsrClkActive  => mmcmLocked(i),
            txData          => timingPhy.data,
            txDataK         => timingPhy.dataK,
            txOutClk        => gtTxClk(i),
            -- Misc.
            loopback        => loopback);

   end generate GEN_VEC;

   rxStatus  <= gtRxStatus(1)  when (timingClockSel = '1') else gtRxStatus(0);
   rxData    <= gtRxData(1)    when (timingClockSel = '1') else gtRxData(0);
   rxDataK   <= gtRxDataK(1)   when (timingClockSel = '1') else gtRxDataK(0);
   rxDispErr <= gtRxDispErr(1) when (timingClockSel = '1') else gtRxDispErr(0);
   rxDecErr  <= gtRxDecErr(1)  when (timingClockSel = '1') else gtRxDecErr(0);
   txStatus  <= gtTxStatus(1)  when (timingClockSel = '1') else gtTxStatus(0);

   U_RXCLK : BUFGMUX
      generic map (
         CLK_SEL_TYPE => "ASYNC")       -- ASYNC, SYNC
      port map (
         O  => rxClk,                   -- 1-bit output: Clock output
         I0 => gtRxClk(0),              -- 1-bit input: Clock input (S=0)
         I1 => gtRxClk(1),              -- 1-bit input: Clock input (S=1)
         S  => timingClockSel);         -- 1-bit input: Clock select

   U_TXCLK : BUFGMUX
      generic map (
         CLK_SEL_TYPE => "ASYNC")       -- ASYNC, SYNC
      port map (
         O  => txClk,                   -- 1-bit output: Clock output
         I0 => gtTxClk(0),              -- 1-bit input: Clock input (S=0)
         I1 => gtTxClk(1),              -- 1-bit input: Clock input (S=1)
         S  => timingClockSel);         -- 1-bit input: Clock select         

   -----------------------
   -- Insert user RX reset
   -----------------------
   rxControl.reset       <= rxCtrl.reset or rxUserRst;
   rxControl.inhibit     <= rxCtrl.inhibit;
   rxControl.polarity    <= rxCtrl.polarity;
   rxControl.bufferByRst <= rxCtrl.bufferByRst;
   rxControl.pllReset    <= rxCtrl.pllReset or rxUserRst;

   --------------
   -- Timing Core
   --------------
   U_TimingCore : entity work.TimingCore
      generic map (
         TPD_G             => TPD_G,
         DEFAULT_CLK_SEL_G => '0',  -- '0': default LCLS-I, '1': default LCLS-II
         USE_TPGMINI_G     => false,
         ASYNC_G           => false,
         AXIL_BASE_ADDR_G  => AXIL_CONFIG_C(TIMING_INDEX_C).baseAddr)
      port map (
         -- GT Interface
         gtTxUsrClk      => txClk,
         gtTxUsrRst      => txRst,
         gtRxRecClk      => rxClk,
         gtRxData        => rxData,
         gtRxDataK       => rxDataK,
         gtRxDispErr     => rxDispErr,
         gtRxDecErr      => rxDecErr,
         gtRxControl     => rxCtrl,
         gtRxStatus      => rxStatus,
         -- Decoded timing message interface
         appTimingClk    => axilClk,
         appTimingRst    => axilRst,
         appTimingBus    => timingBus,
         timingPhy       => open,       -- TPGMINI
         timingClkSel    => timingClockSel,
         -- AXI Lite interface
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(TIMING_INDEX_C),
         axilReadSlave   => axilReadSlaves(TIMING_INDEX_C),
         axilWriteMaster => axilWriteMasters(TIMING_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(TIMING_INDEX_C));

   ---------------------
   -- Timing PHY Monitor
   ---------------------
   U_Monitor : entity work.TimingPhyMonitor
      generic map (
         TPD_G => TPD_G)
      port map (
         rxUserRst       => rxUserRst,
         txUserRst       => txUserRst,
         txDiffCtrl      => txDiffCtrl,
         txPreCursor     => txPreCursor,
         txPostCursor    => txPostCursor,
         loopback        => loopback,
         mmcmRst         => mmcmRst,
         mmcmLocked      => mmcmLocked,
         refClk          => refClk,
         refRst          => refRst,
         txClk           => txClk,
         txRst           => txRst,
         rxClk           => rxClk,
         rxRst           => rxRst,
         -- AXI Lite interface
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(MON_INDEX_C),
         axilReadSlave   => axilReadSlaves(MON_INDEX_C),
         axilWriteMaster => axilWriteMasters(MON_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(MON_INDEX_C));

   ---------------------
   -- Event Header Cache
   ---------------------         
   U_HeaderCache : entity work.EventHeaderCacheWrapper
      generic map (
         TPD_G              => TPD_G,
         NDET_G             => 4,
         USER_AXIS_CONFIG_G => DMA_AXIS_CONFIG_G,
         PIPE_STAGES_G      => 1)
      port map (
         -- Trigger Interface (rxClk domain)
         trigBus         => trigBus,
         -- Readout Interface (tdetClk domain)
         tdetClk         => axilClk,
         tdetRst         => axilRst,
         tdetTiming      => tdetTiming,
         tdetStatus      => tdetStatus,
         -- Event stream (tdetClk domain)
         tdetEventMaster => tdetEventMaster,
         tdetEventSlave  => tdetEventSlave,
         -- Transition stream (tdetClk domain)
         tdetTransMaster => tdetTransMaster,
         tdetTransSlave  => tdetTransSlave,
         -- LCLS RX Timing Interface (rxClk domain)
         rxClk           => rxClk,
         rxRst           => rxRst,
         rxControl       => rxControl,
         timingBus       => timingBus,
         -- LCLS RX Timing Interface (txClk domain)
         txClk           => txClk,
         txRst           => txRst,
         txStatus        => txStatus,
         timingPhy       => timingPhy);

end mapping;
