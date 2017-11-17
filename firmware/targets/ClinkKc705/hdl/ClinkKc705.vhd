-------------------------------------------------------------------------------
-- File       : ClinkKc705.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-02-23
-- Last update: 2016-02-09
-------------------------------------------------------------------------------
-- Description: Example using 10G-BASER Protocol
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Example Project Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;
use work.SsiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity ClinkKc705 is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- Misc. IOs
      fmcLed          : out slv(3 downto 0);
      fmcSfpLossL     : in  slv(3 downto 0);
      fmcTxFault      : in  slv(3 downto 0);
      fmcSfpTxDisable : out slv(3 downto 0);
      fmcSfpRateSel   : out slv(3 downto 0);
      fmcSfpModDef0   : out slv(3 downto 0);
      extRst          : in  sl;
      led             : out slv(7 downto 0);
      -- XADC Ports
      --vPIn            : in  sl;
      --vNIn            : in  sl;
      -- ETH GT Pins
      ethClkP         : in  sl;
      ethClkN         : in  sl;
      ethRxP          : in  sl;
      ethRxN          : in  sl;
      ethTxP          : out sl;
      ethTxN          : out sl);       
end ClinkKc705;

architecture top_level of ClinkKc705 is

   constant IP_ADDR_C      : slv(31 downto 0) := x"0A02A8C0";      -- 192.168.2.10  
   constant MAC_ADDR_C     : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01

   constant CLK_FREQUENCY_C : real    := 125.0E+6;
   constant NUM_SERVERS_C   : integer := 1;
   constant SERVER_PORTS_C  : PositiveArray(NUM_SERVERS_C-1 downto 0) := (0 => 8192);

   constant RSSI_SIZE_C : positive := 2;
   constant AXIS_CONFIG_C : AxiStreamConfigArray(RSSI_SIZE_C-1 downto 0) := (
      0 => ssiAxiStreamConfig(4),
      1 => ssiAxiStreamConfig(4));

   constant NUM_AXIL_C : positive := 2;
   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_C-1 downto 0) := 
      genAxiLiteConfig(NUM_AXIL_C, x"00000000", 16, 8);

   signal txMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);

   signal ibServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);
   signal obServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);

   signal rssiIbMasters : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiIbSlaves  : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObMasters : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObSlaves  : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);

   signal topWriteMaster : AxiLiteWriteMasterType;
   signal topWriteSlave  : AxiLiteWriteSlaveType;
   signal topReadMaster  : AxiLiteReadMasterType;
   signal topReadSlave   : AxiLiteReadSlaveType;

   signal intWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_C-1 downto 0);
   signal intWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_C-1 downto 0);
   signal intReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_C-1 downto 0);
   signal intReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_C-1 downto 0);

   signal clk      : sl;
   signal rst      : sl;
   signal reset    : sl;
   signal phyReady : sl;

begin

   -----------------
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => extRst,
         clk    => clk,
         rstOut => reset);

   ----------------------------
   -- 10GBASE-R Ethernet Module
   ----------------------------
   U_10GigE : entity work.TenGigEthGtx7Wrapper
      generic map (
         TPD_G             => TPD_G,
         -- DMA/MAC Configurations
         NUM_LANE_G        => 1,
         -- QUAD PLL Configurations
         REFCLK_DIV2_G     => true,     -- TRUE: gtClkP/N = 312.5 MHz
         QPLL_REFCLK_SEL_G => "001",    -- GTREFCLK0 selected
         -- AXI Streaming Configurations
         AXIS_CONFIG_G     => (others => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac     => (others => MAC_ADDR_C),
         -- Streaming DMA Interface 
         dmaClk       => (others => clk),
         dmaRst       => (others => rst),
         dmaIbMasters => rxMasters,
         dmaIbSlaves  => rxSlaves,
         dmaObMasters => txMasters,
         dmaObSlaves  => txSlaves,
         -- Misc. Signals
         extRst       => reset,
         phyClk       => clk,
         phyRst       => rst,
         phyReady(0)  => phyReady,
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
         gtClkP       => ethClkP,
         gtClkN       => ethClkN,
         -- MGT Ports
         gtTxP(0)     => ethTxP,
         gtTxN(0)     => ethTxN,
         gtRxP(0)     => ethRxP,
         gtRxN(0)     => ethRxN);  

   -- UDP Servers
   U_UDP : entity work.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => NUM_SERVERS_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Client Generics
         CLIENT_EN_G    => false,
         -- General IPv4/ARP/DHCP Generics
         DHCP_G         => true,
         CLK_FREQ_G     => CLK_FREQUENCY_C,
         COMM_TIMEOUT_G => 30)
      port map (
         -- Local Configurations
         localMac        => MAC_ADDR_C,
         localIp         => IP_ADDR_C,
         -- Interface to Ethernet Media Access Controller (MAC)
         obMacMaster     => rxMasters(0),
         obMacSlave      => rxSlaves(0),
         ibMacMaster     => txMasters(0),
         ibMacSlave      => txSlaves(0),
         -- Interface to UDP Server engine(s)
         obServerMasters => obServerMasters,
         obServerSlaves  => obServerSlaves,
         ibServerMasters => ibServerMasters,
         ibServerSlaves  => ibServerSlaves,
         -- Clock and Reset
         clk             => clk,
         rst             => rst);

   ------------------------------------------
   -- Software's RSSI Server Interface @ 8192
   ------------------------------------------
   U_RssiServer : entity work.RssiCoreWrapper
      generic map (
         TPD_G               => TPD_G,
         MAX_SEG_SIZE_G      => 1024,
         SEGMENT_ADDR_SIZE_G => 7,
         APP_STREAMS_G       => RSSI_SIZE_C,
         APP_STREAM_ROUTES_G => (
            0                => X"00",
            1                => X"01"),
         CLK_FREQUENCY_G     => CLK_FREQUENCY_C,
         TIMEOUT_UNIT_G      => 1.0E-3,  -- In units of seconds
         SERVER_G            => true,
         RETRANSMIT_ENABLE_G => true,
         BYPASS_CHUNKER_G    => false,
         WINDOW_ADDR_SIZE_G  => 3,
         PIPE_STAGES_G       => 1,
         APP_AXIS_CONFIG_G   => AXIS_CONFIG_C,
         TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
         INIT_SEQ_N_G        => 16#80#)
      port map (
         clk_i             => clk,
         rst_i             => rst,
         openRq_i          => '1',
         -- Application Layer Interface
         sAppAxisMasters_i => rssiIbMasters,
         sAppAxisSlaves_o  => rssiIbSlaves,
         mAppAxisMasters_o => rssiObMasters,
         mAppAxisSlaves_i  => rssiObSlaves,
         -- Transport Layer Interface
         sTspAxisMaster_i  => obServerMasters(0),
         sTspAxisSlave_o   => obServerSlaves(0),
         mTspAxisMaster_o  => ibServerMasters(0),
         mTspAxisSlave_i   => ibServerSlaves(0));

   ---------------------------------------
   -- TDEST = 0x0: Register access control   
   ---------------------------------------
   U_SRPv3 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => AXIS_CONFIG_C(0))
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => clk,
         sAxisRst         => rst,
         sAxisMaster      => rssiObMasters(0),
         sAxisSlave       => rssiObSlaves(0),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => clk,
         mAxisRst         => rst,
         mAxisMaster      => rssiIbMasters(0),
         mAxisSlave       => rssiIbSlaves(0),
         -- Master AXI-Lite Interface (axilClk domain)
         axilClk          => clk,
         axilRst          => rst,
         mAxilReadMaster  => topReadMaster,
         mAxilReadSlave   => topReadSlave,
         mAxilWriteMaster => topWriteMaster,
         mAxilWriteSlave  => topWriteSlave);

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => clk,
         axiClkRst           => rst,
         sAxiWriteMasters(0) => topWriteMaster,
         sAxiWriteSlaves(0)  => topWriteSlave,
         sAxiReadMasters(0)  => topReadMaster,
         sAxiReadSlaves(0)   => topReadSlave,
         mAxiWriteMasters    => intWriteMasters,
         mAxiWriteSlaves     => intWriteSlaves,
         mAxiReadMasters     => intReadMasters,
         mAxiReadSlaves      => intReadSlaves);

   U_Version : entity work.AxiVersion
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         CLK_PERIOD_G => (1.0/CLK_FREQUENCY_C))
      port map (
         -- AXI-Lite Interface
         axiClk         => clk,
         axiRst         => rst,
         axiReadMaster  => intReadMasters(0),
         axiReadSlave   => intReadSlaves(0),
         axiWriteMaster => intWriteMasters(0),
         axiWriteSlave  => intWriteSlaves(0));

   ---------------------------------------
   -- Application
   ---------------------------------------
   rssiIbMasters(1) <= AXI_STREAM_MASTER_INIT_C;
   --rssiIbSlaves(1),
   --rssiObMasters(1),
   rssiObSlaves(1) <= AXI_STREAM_SLAVE_FORCE_C;

   intReadSlaves(1)  <= AXI_LITE_READ_SLAVE_INIT_C;
   intWriteSlaves(1) <= AXI_LITE_WRITE_SLAVE_INIT_C;

   ----------------
   -- Misc. Signals
   ----------------
   led(7) <= phyReady;
   led(6) <= phyReady;
   led(5) <= phyReady;
   led(4) <= phyReady;
   led(3) <= phyReady;
   led(2) <= phyReady;
   led(1) <= phyReady;
   led(0) <= phyReady;

   fmcLed          <= not(fmcSfpLossL);
   fmcSfpTxDisable <= (others => '0');
   fmcSfpRateSel   <= (others => '1');
   fmcSfpModDef0   <= (others => '0');
   
end top_level;

