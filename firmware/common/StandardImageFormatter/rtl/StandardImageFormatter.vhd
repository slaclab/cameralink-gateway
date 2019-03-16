-------------------------------------------------------------------------------
-- File       : StandardImageFormatter.vhd
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

entity StandardImageFormatter is
   generic (
      TPD_G            : time                := 1 ns;
      AXI_ADDR_WIDTH_C : positive            := 30;  -- 2^30 = 1GB buffer
      AXIS_CONFIG_G    : AxiStreamConfigType := ssiAxiStreamConfig(4);
      AXIL_BASE_ADDR_G : slv(31 downto 0)    := x"0000_0000");
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- AXI Stream Interface (axilClk domain)
      sAxisMaster     : in  AxiStreamMasterType;
      sAxisSlave      : out AxiStreamSlaveType;
      mAxisMaster     : out AxiStreamMasterType;
      mAxisSlave      : in  AxiStreamSlaveType;
      -- AXI MEM Interface (axilClk domain)
      axiOffset       : in  slv(63 downto 0);  --! Used to apply an address offset to the master AXI transactions
      axiWriteMasters : out AxiWriteMasterArray(1 downto 0);
      axiWriteSlaves  : in  AxiWriteSlaveArray(1 downto 0);
      axiReadMasters  : out AxiReadMasterArray(1 downto 0);
      axiReadSlaves   : in  AxiReadSlaveArray(1 downto 0));
end StandardImageFormatter;

architecture mapping of StandardImageFormatter is

   constant AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => AXI_ADDR_WIDTH_C,  -- 2^30 = 1GB buffer
      DATA_BYTES_C => 16,                -- 16 bytes = 128-bits
      ID_BITS_C    => 2,
      LEN_BITS_C   => 8);                -- Up to 4kB bursting

   constant AXIS_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(AXI_CONFIG_C.DATA_BYTES_C, TKEEP_COMP_C, TUSER_FIRST_LAST_C, 8, 2);  -- Match the AXIS width to AXI width     

   constant NUM_AXIL_MASTERS_C : positive := 2;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 14, 13);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal initLutReadMaster  : AxiLiteReadMasterType;
   signal initLutReadSlave   : AxiLiteReadSlaveType;
   signal initLutWriteMaster : AxiLiteWriteMasterType;
   signal initLutWriteSlave  : AxiLiteWriteSlaveType;

   signal rxAxisMaster : AxiStreamMasterType;
   signal rxAxisSlave  : AxiStreamSlaveType;
   signal txAxisMaster : AxiStreamMasterType;
   signal txAxisSlave  : AxiStreamSlaveType;

   signal axilReq : AxiLiteReqType;
   signal axilAck : AxiLiteAckType;

   signal wrRam    : sl;
   signal row      : slv(10 downto 0);
   signal remapRow : slv(10 downto 0);

begin

   -----------------------
   -- AxiLiteMaster Bridge
   -----------------------
   U_AxiLiteMaster : entity work.AxiLiteMaster
      generic map (
         TPD_G => TPD_G)
      port map (
         req             => axilReq,
         ack             => axilAck,
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilWriteMaster => initLutWriteMaster,
         axilWriteSlave  => initLutWriteSlave,
         axilReadMaster  => initLutReadMaster,
         axilReadSlave   => initLutReadSlave);

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_AXIL_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteMasters(1) => initLutWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiWriteSlaves(1)  => initLutWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadMasters(1)  => initLutReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         sAxiReadSlaves(1)   => initLutReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   -------------------------      
   -- LUT for remapping rows
   -------------------------      
   U_ROW_REMAP_LUT : entity work.AxiDualPortRam
      generic map (
         TPD_G        => TPD_G,
         SYS_WR_EN_G  => true,
         COMMON_CLK_G => true,
         ADDR_WIDTH_G => 11,            -- 2k
         DATA_WIDTH_G => 11)            -- 2k
      port map (
         -- Axi Port
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(0),
         axiReadSlave   => axilReadSlaves(0),
         axiWriteMaster => axilWriteMasters(0),
         axiWriteSlave  => axilWriteSlaves(0),
         -- Standard Port
         clk            => axilClk,
         we             => wrRam,
         addr           => row,
         din            => row,
         dout           => remapRow);

   -------------------------------- 
   -- Resize the Inbound AXI Stream
   -------------------------------- 
   U_RxResize : entity work.AxiStreamResize
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         READY_EN_G          => true,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_C)
      port map (
         -- Clock and reset
         axisClk     => axilClk,
         axisRst     => axilRst,
         -- Slave Port
         sAxisMaster => sAxisMaster,
         sAxisSlave  => sAxisSlave,
         -- Master Port
         mAxisMaster => rxAxisMaster,
         mAxisSlave  => rxAxisSlave);

   -------------------------------- 
   -- Resize the Inbound AXI Stream
   -------------------------------- 
   U_Fsm : entity work.StandardImageFormatterFsm
      generic map (
         TPD_G         => TPD_G,
         AXI_CONFIG_G  => AXI_CONFIG_C,
         AXIS_CONFIG_G => AXIS_CONFIG_C)
      port map (
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(1),
         axilReadSlave   => axilReadSlaves(1),
         axilWriteMaster => axilWriteMasters(1),
         axilWriteSlave  => axilWriteSlaves(1),
         -- Row Remapping LUT Interface (axilClk domain)
         wrRam           => wrRam,
         row             => row,
         remapRow        => remapRow,
         -- AXI Stream Interface (axilClk domain)
         sAxisMaster     => rxAxisMaster,
         sAxisSlave      => rxAxisSlave,
         mAxisMaster     => txAxisMaster,
         mAxisSlave      => txAxisSlave,
         -- AXI MEM Interface (axilClk domain)
         axiOffset       => axiOffset,
         axiWriteMasters => axiWriteMasters,
         axiWriteSlaves  => axiWriteSlaves,
         axiReadMasters  => axiReadMasters,
         axiReadSlaves   => axiReadSlaves);

   ---------------------------------
   -- Resize the Outbound AXI Stream
   --------------------------------- 
   U_TxResize : entity work.AxiStreamResize
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         READY_EN_G          => true,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_G)
      port map (
         -- Clock and reset
         axisClk     => axilClk,
         axisRst     => axilRst,
         -- Slave Port
         sAxisMaster => txAxisMaster,
         sAxisSlave  => txAxisSlave,
         -- Master Port
         mAxisMaster => mAxisMaster,
         mAxisSlave  => mAxisSlave);

end mapping;
