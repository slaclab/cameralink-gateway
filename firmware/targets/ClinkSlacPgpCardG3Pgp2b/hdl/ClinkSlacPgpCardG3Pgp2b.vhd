-------------------------------------------------------------------------------
-- File       : ClinkSlacPgpCardG3Pgp2b.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Camera link gateway PCIe card with PGPv2b
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library lcls2_pgp_fw_lib;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity ClinkSlacPgpCardG3Pgp2b is
   generic (
      TPD_G          : time    := 1 ns;
      ROGUE_SIM_EN_G : boolean := false;
      BUILD_INFO_G   : BuildInfoType);
   port (
      ---------------------
      --  Application Ports
      ---------------------
      -- PGP GT Serial Ports
      pgpRefClkP : in    sl;
      pgpRefClkN : in    sl;
      pgpRxP     : in    slv(7 downto 0);
      pgpRxN     : in    slv(7 downto 0);
      pgpTxP     : out   slv(7 downto 0);
      pgpTxN     : out   slv(7 downto 0);
      -- EVR GT Serial Ports
      evrRefClkP : in    slv(1 downto 0);
      evrRefClkN : in    slv(1 downto 0);
      evrMuxSel  : out   slv(1 downto 0);
      evrRxP     : in    sl;
      evrRxN     : in    sl;
      evrTxP     : out   sl;
      evrTxN     : out   sl;
      -- User LEDs
      ledDbg     : out   sl;
      ledRedL    : out   slv(5 downto 0);
      ledBlueL   : out   slv(5 downto 0);
      ledGreenL  : out   slv(5 downto 0);
      --------------
      --  Core Ports
      --------------
      -- FLASH Interface
      flashAddr  : out   slv(28 downto 0);
      flashData  : inout slv(15 downto 0);
      flashAdv   : out   sl;
      flashCeL   : out   sl;
      flashOeL   : out   sl;
      flashWeL   : out   sl;
      -- PCIe Ports
      pciRstL    : in    sl;
      pciRefClkP : in    sl;            -- 100 MHz
      pciRefClkN : in    sl;            -- 100 MHz
      pciRxP     : in    slv(3 downto 0);
      pciRxN     : in    slv(3 downto 0);
      pciTxP     : out   slv(3 downto 0);
      pciTxN     : out   slv(3 downto 0));
end ClinkSlacPgpCardG3Pgp2b;

architecture top_level of ClinkSlacPgpCardG3Pgp2b is

   constant DMA_SIZE_C        : positive := 1;

   constant NUM_AXIL_MASTERS_C : positive := 2;

   constant HW_INDEX_C  : natural := 0;
   constant APP_INDEX_C : natural := 1;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"0080_0000", 23, 22);

   signal axilClk          : sl;
   signal axilRst          : sl;
   signal axilReadMaster   : AxiLiteReadMasterType;
   signal axilReadSlave    : AxiLiteReadSlaveType;
   signal axilWriteMaster  : AxiLiteWriteMasterType;
   signal axilWriteSlave   : AxiLiteWriteSlaveType;
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaObMasters : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaObSlaves  : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal dmaIbMasters : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaIbSlaves  : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal pgpIbMasters : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0)     := (others => AXI_STREAM_MASTER_INIT_C);
   signal pgpIbSlaves  : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0)      := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal pgpObMasters : AxiStreamQuadMasterArray(DMA_SIZE_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
   signal pgpObSlaves  : AxiStreamQuadSlaveArray(DMA_SIZE_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));

   signal eventTrigMsgMasters : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal eventTrigMsgSlaves  : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal eventTrigMsgCtrl    : AxiStreamCtrlArray(DMA_SIZE_C-1 downto 0)   := (others => AXI_STREAM_CTRL_UNUSED_C);

   signal eventTimingMsgMasters : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal eventTimingMsgSlaves  : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

begin

   axilClk <= dmaClk;
   axilRst <= dmaRst;

   ----------------------- 
   -- AXI-PCIE-CORE Module
   ----------------------- 
   U_Core : entity axi_pcie_core.AxiPciePgpCardG3Core
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
         ROGUE_SIM_CH_COUNT_G => 4,     -- 4 Virtual Channels per DMA lane
         BUILD_INFO_G         => BUILD_INFO_G,
         DMA_SIZE_G           => DMA_SIZE_C)
      port map (
         ------------------------      
         --  Top Level Interfaces
         ------------------------        
         -- DMA Interfaces
         dmaClk         => dmaClk,
         dmaRst         => dmaRst,
         dmaObMasters   => dmaObMasters,
         dmaObSlaves    => dmaObSlaves,
         dmaIbMasters   => dmaIbMasters,
         dmaIbSlaves    => dmaIbSlaves,
         -- AXI-Lite Interface
         appClk         => axilClk,
         appRst         => axilRst,
         appReadMaster  => axilReadMaster,
         appReadSlave   => axilReadSlave,
         appWriteMaster => axilWriteMaster,
         appWriteSlave  => axilWriteSlave,
         --------------
         --  Core Ports
         --------------   
         -- Boot Memory Ports
         flashAddr      => flashAddr,
         flashData      => flashData,
         flashAdv       => flashAdv,
         flashCeL       => flashCeL,
         flashOeL       => flashOeL,
         flashWeL       => flashWeL,
         -- PCIe Ports 
         pciRstL        => pciRstL,
         pciRefClkP     => pciRefClkP,
         pciRefClkN     => pciRefClkN,
         pciRxP         => pciRxP,
         pciRxN         => pciRxN,
         pciTxP         => pciTxP,
         pciTxN         => pciTxN);

   ledDbg    <= '0';
   ledRedL   <= (others => '1');
   ledBlueL  <= (others => '1');
   ledGreenL <= (others => '1');
   evrMuxSel <= (others => '0');

   U_TermGts : entity surf.Gtpe2ChannelDummy
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => ROGUE_SIM_EN_G,
         WIDTH_G      => 1)
      port map (
         refClk   => axilClk,
         gtRxP(0) => evrRxP,
         gtRxN(0) => evrRxN,
         gtTxP(0) => evrTxP,
         gtTxN(0) => evrTxN);

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

   U_App : entity work.Application
      generic map (
         TPD_G             => TPD_G,
         AXI_BASE_ADDR_G   => AXIL_CONFIG_C(APP_INDEX_C).baseAddr,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         DMA_SIZE_G        => DMA_SIZE_C)
      port map (
         -- AXI-Lite Interface (axilClk domain)
         axilClk               => axilClk,
         axilRst               => axilRst,
         axilReadMaster        => axilReadMasters(APP_INDEX_C),
         axilReadSlave         => axilReadSlaves(APP_INDEX_C),
         axilWriteMaster       => axilWriteMasters(APP_INDEX_C),
         axilWriteSlave        => axilWriteSlaves(APP_INDEX_C),
         -- PGP Streams (axilClk domain)
         pgpIbMasters          => pgpIbMasters,
         pgpIbSlaves           => pgpIbSlaves,
         pgpObMasters          => pgpObMasters,
         pgpObSlaves           => pgpObSlaves,
         -- Trigger Event streams (axilClk domain)
         eventTrigMsgMasters   => eventTrigMsgMasters,
         eventTrigMsgSlaves    => eventTrigMsgSlaves,
         eventTimingMsgMasters => eventTimingMsgMasters,
         eventTimingMsgSlaves  => eventTimingMsgSlaves,
         -- DMA Interface (dmaClk domain)
         dmaClk                => dmaClk,
         dmaRst                => dmaRst,
         dmaObMasters          => dmaObMasters,
         dmaObSlaves           => dmaObSlaves,
         dmaIbMasters          => dmaIbMasters,
         dmaIbSlaves           => dmaIbSlaves);

   ------------------
   -- Hardware Module
   ------------------
   U_HSIO : entity work.SlacPgpCardG3Hsio
      generic map (
         TPD_G               => TPD_G,
         ROGUE_SIM_EN_G      => ROGUE_SIM_EN_G,
         NUM_PGP_LANES_G     => DMA_SIZE_C,
         DMA_AXIS_CONFIG_G   => DMA_AXIS_CONFIG_C,
         AXIL_CLK_FREQ_G     => DMA_CLK_FREQ_C,
         AXI_BASE_ADDR_G     => AXIL_CONFIG_C(HW_INDEX_C).baseAddr,
         EN_LCLS_I_TIMING_G  => true,
         EN_LCLS_II_TIMING_G => true)
      port map (
         ------------------------      
         --  Top Level Interfaces
         ------------------------    
         -- AXI-Lite Interface (axilClk domain)
         axilClk               => axilClk,
         axilRst               => axilRst,
         axilReadMaster        => axilReadMasters(HW_INDEX_C),
         axilReadSlave         => axilReadSlaves(HW_INDEX_C),
         axilWriteMaster       => axilWriteMasters(HW_INDEX_C),
         axilWriteSlave        => axilWriteSlaves(HW_INDEX_C),
         -- PGP Streams (axilClk domain)
         pgpIbMasters          => pgpIbMasters,
         pgpIbSlaves           => pgpIbSlaves,
         pgpObMasters          => pgpObMasters,
         pgpObSlaves           => pgpObSlaves,
         -- Trigger / event interfaces
         triggerClk            => axilClk,
         triggerRst            => axilRst,
         triggerData           => open,
         eventClk              => axilClk,
         eventRst              => axilRst,
         eventTrigMsgMasters   => eventTrigMsgMasters,
         eventTrigMsgSlaves    => eventTrigMsgSlaves,
         eventTrigMsgCtrl      => eventTrigMsgCtrl,
         eventTimingMsgMasters => eventTimingMsgMasters,
         eventTimingMsgSlaves  => eventTimingMsgSlaves,
         ------------------
         --  Hardware Ports
         ------------------    
         -- PGP GT Serial Ports
         pgpRefClkP            => pgpRefClkP,
         pgpRefClkN            => pgpRefClkN,
         pgpRxP                => pgpRxP,
         pgpRxN                => pgpRxN,
         pgpTxP                => pgpTxP,
         pgpTxN                => pgpTxN,
         -- EVR GT Serial Ports
         evrRefClkP            => evrRefClkP,
         evrRefClkN            => evrRefClkN);

end top_level;
