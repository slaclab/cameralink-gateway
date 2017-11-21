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
      -- ETH GT Pins
      gtClkP          : in  sl;
      gtClkN          : in  sl;
      gtRxP           : in  sl;
      gtRxN           : in  sl;
      gtTxP           : out sl;
      gtTxN           : out sl);       
end ClinkKc705;

architecture top_level of ClinkKc705 is

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrl    : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   constant NUM_AXIL_C : positive := 2;
   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_C-1 downto 0) := 
      genAxiLiteConfig(NUM_AXIL_C, x"00000000", 16, 8);

   signal topWriteMaster  : AxiLiteWriteMasterType;
   signal topWriteSlave   : AxiLiteWriteSlaveType;
   signal topReadMaster   : AxiLiteReadMasterType;
   signal topReadSlave    : AxiLiteReadSlaveType;

   signal intWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_C-1 downto 0);
   signal intWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_C-1 downto 0);
   signal intReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_C-1 downto 0);
   signal intReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_C-1 downto 0);

   signal pgpTxOut : Pgp2bTxOutType;
   signal pgpRxOut : Pgp2bRxOutType;

   signal clk      : sl;
   signal rst      : sl;

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
         pgpRxCtrl    => rxCtrl,
         -- GT Pins
         gtClkP       => gtClkP,
         gtClkN       => gtClkN,
         gtTxP        => gtTxP,
         gtTxN        => gtTxN,
         gtRxP        => gtRxP,
         gtRxN        => gtRxN);

   txMasters(3 downto 2) <= (others=>AXI_STREAM_MASTER_INIT_C);
   rxCtrl(3 downto 1)    <= (others=>AXI_STREAM_CTRL_INIT_C);

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
         sAxisCtrl        => rxCtrl(0),
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

   txMasters(1) <= AXI_STREAM_MASTER_INIT_C;

   intReadSlaves(1)  <= AXI_LITE_READ_SLAVE_INIT_C;
   intWriteSlaves(1) <= AXI_LITE_WRITE_SLAVE_INIT_C;

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

