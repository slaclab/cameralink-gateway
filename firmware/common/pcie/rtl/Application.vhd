-------------------------------------------------------------------------------
-- File       : Application.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-26
-- Last update: 2019-02-01
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
use work.AppPkg.all;

entity Application is
   generic (
      TPD_G           : time             := 1 ns;
      AXI_BASE_ADDR_G : slv(31 downto 0) := x"0080_0000");
   port (
      -- AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- PGP Streams (axilClk domain)
      pgpIbMasters    : out AxiStreamMasterArray(3 downto 0);
      pgpIbSlaves     : in  AxiStreamSlaveArray(3 downto 0);
      pgpObMasters    : in  AxiStreamMasterArray(3 downto 0);
      pgpObSlaves     : out AxiStreamSlaveArray(3 downto 0);
      -- Event streams (axilClk domain)
      tdetEventMaster : in  AxiStreamMasterArray(3 downto 0);
      tdetEventSlave  : out AxiStreamSlaveArray(3 downto 0);
      -- Transition streams (axilClk domain)
      tdetTransMaster : in  AxiStreamMasterArray(3 downto 0);
      tdetTransSlave  : out AxiStreamSlaveArray(3 downto 0);
      -- DMA Interface (dmaClk domain)
      dmaClk          : in  sl;
      dmaRst          : in  sl;
      dmaIbMasters    : out AxiStreamMasterArray(3 downto 0);
      dmaIbSlaves     : in  AxiStreamSlaveArray(3 downto 0);
      dmaObMasters    : in  AxiStreamMasterArray(3 downto 0);
      dmaObSlaves     : out AxiStreamSlaveArray(3 downto 0);
      -- DDR MEM Interface (ddrClk domain)
      ddrClk          : in  sl;
      ddrRst          : in  sl;
      ddrWriteMaster  : out AxiWriteMasterType;
      ddrWriteSlave   : in  AxiWriteSlaveType;
      ddrReadMaster   : out AxiReadMasterType;
      ddrReadSlave    : in  AxiReadSlaveType);
end Application;

architecture mapping of Application is

   constant NUM_AXIL_MASTERS_C : positive := 1;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXI_BASE_ADDR_G, 20, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal ddrWriteMasters : AxiWriteMasterArray(7 downto 0);
   signal ddrWriteSlaves  : AxiWriteSlaveArray(7 downto 0);
   signal ddrReadMasters  : AxiReadMasterArray(7 downto 0);
   signal ddrReadSlaves   : AxiReadSlaveArray(7 downto 0);


begin

   dmaIbMasters <= pgpObMasters;
   pgpObSlaves  <= dmaIbSlaves;

   pgpIbMasters <= dmaObMasters;
   dmaObSlaves  <= pgpIbSlaves;

   tdetTransSlave <= (others => AXI_STREAM_SLAVE_FORCE_C);
   tdetEventSlave <= (others => AXI_STREAM_SLAVE_FORCE_C);

   axilReadSlaves  <= (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);
   axilWriteSlaves <= (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);

   ddrReadMasters  <= (others => AXI_READ_MASTER_FORCE_C);
   ddrWriteMasters <= (others => AXI_WRITE_MASTER_FORCE_C);

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_AXIL_XBAR : entity work.AxiLiteCrossbar
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

   ---------------------
   -- AXI Crossbar
   ---------------------
   U_AXI_XBAR : entity work.DdrAxiXbar
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Slave Interfaces
         sAxiClk          => axilClk,
         sAxiRst          => axilRst,
         sAxiWriteMasters => ddrWriteMasters,
         sAxiWriteSlaves  => ddrWriteSlaves,
         sAxiReadMasters  => ddrReadMasters,
         sAxiReadSlaves   => ddrReadSlaves,
         -- Master Interface
         mAxiClk          => ddrClk,
         mAxiRst          => ddrRst,
         mAxiWriteMaster  => ddrWriteMaster,
         mAxiWriteSlave   => ddrWriteSlave,
         mAxiReadMaster   => ddrReadMaster,
         mAxiReadSlave    => ddrReadSlave);

end mapping;
