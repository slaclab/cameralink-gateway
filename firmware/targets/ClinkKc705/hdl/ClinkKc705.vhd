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
use work.Pgp2bPkg.all;

library unisim;
use unisim.vcomponents.all;

entity ClinkKc705 is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      extRst          : in  sl;
      led             : out slv(7 downto 0);
      -- XADC Ports
      vPIn            : in  sl;
      vNIn            : in  sl;
      -- Clink Ports
      cbl0Half0P      : inout slv(4 downto 0); --  2,  4,  5,  6, 3
      cbl0Half0M      : inout slv(4 downto 0); -- 15, 17, 18, 19 16
      cbl0Half1P      : inout slv(4 downto 0); --  8, 10, 11, 12,  9
      cbl0Half1M      : inout slv(4 downto 0); -- 21, 23, 24, 25, 22
      cbl0SerP        : out   sl; -- 20
      cbl0SerM        : out   sl; -- 7
      cbl1Half0P      : inout slv(4 downto 0); --  2,  4,  5,  6, 3
      cbl1Half0M      : inout slv(4 downto 0); -- 15, 17, 18, 19 16
      cbl1Half1P      : inout slv(4 downto 0); --  8, 10, 11, 12,  9
      cbl1Half1M      : inout slv(4 downto 0); -- 21, 23, 24, 25, 22
      cbl1SerP        : out   sl; -- 20
      cbl1SerM        : out   sl; -- 7
      -- ETH GT Pins
      gtClkP          : in  sl;
      gtClkN          : in  sl;
      gtRxP           : in  sl;
      gtRxN           : in  sl;
      gtTxP           : out sl;
      gtTxN           : out sl);       
end ClinkKc705;

architecture top_level of ClinkKc705 is

   constant AXIS_128_C : AxiStreamConfigType := ssiAxiStreamConfig(dataBytes=>16,tDestBits=>0);
   constant AXIS_32_C  : AxiStreamConfigType := ssiAxiStreamConfig(dataBytes=>4, tDestBits=>0);

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrls   : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   constant NUM_AXIL_C : positive := 2;
   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_C-1 downto 0) := 
      genAxiLiteConfig(NUM_AXIL_C, x"00000000", 24, 16);

   signal topWriteMaster  : AxiLiteWriteMasterType;
   signal topWriteSlave   : AxiLiteWriteSlaveType;
   signal topReadMaster   : AxiLiteReadMasterType;
   signal topReadSlave    : AxiLiteReadSlaveType;

   signal intWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_C-1 downto 0);
   signal intWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_C-1 downto 0);
   signal intReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_C-1 downto 0);
   signal intReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_C-1 downto 0);

   signal dataMasters     : AxiStreamMasterArray(0 downto 0);
   signal dataSlaves      : AxiStreamSlaveArray(0 downto 0);

   signal intMasterA      : AxiStreamMasterType;
   signal intMasterB      : AxiStreamMasterType;
   signal intSlave        : AxiStreamSlaveType;

   signal mUartMasters    : AxiStreamMasterArray(0 downto 0);
   signal mUartSlaves     : AxiStreamSlaveArray(0 downto 0);
   signal sUartMasters    : AxiStreamMasterArray(0 downto 0);
   signal sUartCtrls      : AxiStreamCtrlArray(0 downto 0);

   signal pgpTxOut : Pgp2bTxOutType;
   signal pgpRxOut : Pgp2bRxOutType;

   signal clk      : sl;
   signal rst      : sl;

   signal dlyClk : sl;
   signal dlyRst : sl;

   signal ccCount : slv(11 downto 0);
   signal camCtrl : Slv4Array(0 downto 0);

   attribute MARK_DEBUG : string;
   attribute MARK_DEBUG of intMasterA  : signal is "TRUE";
   attribute MARK_DEBUG of intSlave    : signal is "TRUE";
   attribute MARK_DEBUG of dataMasters : signal is "TRUE";
   attribute MARK_DEBUG of dataSlaves  : signal is "TRUE";

begin

   U_PGP : entity work.Pgp2bGtx7VarLatWrapper
      generic map (
         TPD_G => TPD_G)
      port map (
         -- External Reset
         extRst       => extRst,
         -- Clock and Reset
         pgpClk       => clk,
         pgpRst       => rst,
         -- Non VC TX Signals
         pgpTxIn      => PGP2B_TX_IN_INIT_C,
         pgpTxOut     => pgpTxOut,
         -- Non VC RX Signals
         pgpRxIn      => PGP2B_RX_IN_INIT_C,
         pgpRxOut     => pgpRxOut,
         -- Frame TX Interface
         pgpTxMasters => txMasters,
         pgpTxSlaves  => txSlaves,
         -- Frame RX Interface
         pgpRxMasters => rxMasters,
         pgpRxCtrl    => rxCtrls,
         -- GT Pins
         gtClkP       => gtClkP,
         gtClkN       => gtClkN,
         gtTxP        => gtTxP,
         gtTxN        => gtTxN,
         gtRxP        => gtRxP,
         gtRxN        => gtRxN);

   txMasters(3) <= AXI_STREAM_MASTER_INIT_C;
   rxCtrls(3)   <= AXI_STREAM_CTRL_UNUSED_C;

   U_ClkGen : entity work.ClockManager7
      generic map (
         TPD_G               => TPD_G,
         INPUT_BUFG_G        => true,
         FB_BUFG_G           => true,
         OUTPUT_BUFG_G       => true, 
         NUM_CLOCKS_G        => 1,
         BANDWIDTH_G         => "OPTIMIZED",
         CLKIN_PERIOD_G      => 6.4, -- 156.25Mhz
         DIVCLK_DIVIDE_G     => 1,
         CLKFBOUT_MULT_F_G   => 6.4, -- 1.00Ghz
         CLKOUT0_DIVIDE_F_G  => 5.0) -- 200Mhz
      port map (
         clkIn            => clk,
         rstIn            => rst,
         clkOut(0)        => dlyClk,
         rstOut(0)        => dlyRst);

   ---------------------------------------
   -- TDEST = 0x0: Register access control   
   ---------------------------------------
   U_SRPv3 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => false,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => clk,
         sAxisRst         => rst,
         sAxisMaster      => rxMasters(0),
         sAxisCtrl        => rxCtrls(0),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => clk,
         mAxisRst         => rst,
         mAxisMaster      => txMasters(0),
         mAxisSlave       => txSlaves(0),
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

   U_AxiVersion : entity work.AxiVersion
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         CLK_PERIOD_G => 6.4e-9)
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

   -- Drive CC bit when opcode received
   U_CcGen: process ( clk ) begin
      if rising_edge(clk) then
         if rst = '1' then
            ccCount <= (others=>'0') after TPD_G;
            camCtrl <= (others=>(others=>'0')) after TPD_G;
         else
            if pgpRxOut.opCodeEn = '1' then
               ccCount <= (others=>'1') after TPD_G;
               camCtrl(0)(0) <= '1' after TPD_G;
            elsif ccCount = 0 then
               camCtrl(0)(0) <= '0' after TPD_G;
            else
               ccCount <= ccCount - 1 after TPD_G;
            end if;
         end if;
      end if;
   end process;

   U_ClinkTop : entity work.ClinkTop
      generic map (
         TPD_G              => TPD_G,
         UART_READY_EN_G    => false,
         DATA_AXIS_CONFIG_G => AXIS_128_C,
         UART_AXIS_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         cbl0Half0P      => cbl0Half0P,
         cbl0Half0M      => cbl0Half0M,
         cbl0Half1P      => cbl0Half1P,
         cbl0Half1M      => cbl0Half1M,
         cbl0SerP        => cbl0SerP,
         cbl0SerM        => cbl0SerM,
         cbl1Half0P      => cbl1Half0P,
         cbl1Half0M      => cbl1Half0M,
         cbl1Half1P      => cbl1Half1P,
         cbl1Half1M      => cbl1Half1M,
         cbl1SerP        => cbl1SerP,
         cbl1SerM        => cbl1SerM,
         -- System clock and reset, 200Mhz
         dlyClk          => dlyClk,
         dlyRst          => dlyRst,
         sysClk          => clk,
         sysRst          => rst,
         camCtrl         => camCtrl,
         dataClk         => clk,
         dataRst         => rst,
         dataMasters     => dataMasters,
         dataSlaves      => dataSlaves,
         uartClk         => clk,
         uartRst         => rst,
         sUartMasters    => sUartMasters,
         sUartSlaves     => open,
         sUartCtrls      => sUartCtrls,
         mUartMasters    => mUartMasters,
         mUartSlaves     => mUartSlaves,
         axilClk         => clk,
         axilRst         => rst,
         axilReadMaster  => intReadMasters(1),
         axilReadSlave   => intReadSlaves(1),
         axilWriteMaster => intWriteMasters(1),
         axilWriteSlave  => intWriteSlaves(1));

   rxCtrls(1)      <= AXI_STREAM_CTRL_UNUSED_C;

   sUartMasters(0) <= rxMasters(2);
   rxCtrls(2)      <= sUartCtrls(0);

   txMasters(2)   <= mUartMasters(0);
   mUartSlaves(0) <= txSlaves(2);

   U_DataFifoA: entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => 12,
         FIFO_PAUSE_THRESH_G => 500,
         SLAVE_AXI_CONFIG_G  => AXIS_128_C,
         MASTER_AXI_CONFIG_G => AXIS_32_C)
      port map (
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => dataMasters(0),
         sAxisSlave  => dataSlaves(0),
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => intMasterA,
         mAxisSlave  => intSlave);

   -- Force 32-bit alignment
   process(intMasterA) begin
      intMasterB <= intMasterA;
      intMasterB.tKeep <= (others=>'1');
   end process;

   U_DataFifoB: entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_PAUSE_THRESH_G => 500,
         SLAVE_AXI_CONFIG_G  => AXIS_32_C,
         MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => intMasterB,
         sAxisSlave  => intSlave,
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => txMasters(1),
         mAxisSlave  => txSlaves(1));

   ----------------
   -- Misc. Signals
   ----------------
   led(7) <= '0';
   led(6) <= '0';
   led(5) <= '0';
   led(4) <= '0';
   led(3) <= '1';
   led(2) <= '0';
   led(1) <= pgpTxOut.linkReady and not(rst);
   led(0) <= pgpRxOut.linkReady and not(rst);

end top_level;

