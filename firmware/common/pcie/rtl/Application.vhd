-------------------------------------------------------------------------------
-- File       : Application.vhd
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
use work.AppPkg.all;

entity Application is
   generic (
      TPD_G           : time             := 1 ns;
      AXI_BASE_ADDR_G : slv(31 downto 0) := x"00C0_0000");
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
      -- Trigger Event streams (axilClk domain)
      trigMasters     : in  AxiStreamMasterArray(3 downto 0);
      trigSlaves      : out AxiStreamSlaveArray(3 downto 0);
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

   constant AXI_OFFSET_C : Slv64Array(3 downto 0) := (
      0 => x"0000_0000_0000_0000",
      1 => x"0000_0000_4000_0000",
      2 => x"0000_0000_8000_0000",
      3 => x"0000_0000_C000_0000");

   constant NUM_AXIL_MASTERS_C : positive := 4;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXI_BASE_ADDR_G, 22, 20);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal axiWriteMasters : AxiWriteMasterArray(7 downto 0);
   signal axiWriteSlaves  : AxiWriteSlaveArray(7 downto 0);
   signal axiReadMasters  : AxiReadMasterArray(7 downto 0);
   signal axiReadSlaves   : AxiReadSlaveArray(7 downto 0);


begin

   --------------------
   -- AXI-Lite Crossbar
   --------------------
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

   ---------------
   -- AXI Crossbar
   ---------------
   U_AXI_XBAR : entity work.DdrAxiXbar
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Slave Interfaces
         sAxiClk          => axilClk,
         sAxiRst          => axilRst,
         sAxiWriteMasters => axiWriteMasters,
         sAxiWriteSlaves  => axiWriteSlaves,
         sAxiReadMasters  => axiReadMasters,
         sAxiReadSlaves   => axiReadSlaves,
         -- Master Interface
         mAxiClk          => ddrClk,
         mAxiRst          => ddrRst,
         mAxiWriteMaster  => ddrWriteMaster,
         mAxiWriteSlave   => ddrWriteSlave,
         mAxiReadMaster   => ddrReadMaster,
         mAxiReadSlave    => ddrReadSlave);

   -------------------
   -- Application Lane
   -------------------
   GEN_VEC :
   for i in 3 downto 0 generate
      U_Lane : entity work.AppLane
         generic map (
            TPD_G           => TPD_G,
            AXI_BASE_ADDR_G => AXIL_CONFIG_C(i).baseAddr)
         port map (
            -- AXI-Lite Interface
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i),
            -- PGP Streams (axilClk domain)
            pgpIbMaster     => pgpIbMasters(i),
            pgpIbSlave      => pgpIbSlaves(i),
            pgpObMaster     => pgpObMasters(i),
            pgpObSlave      => pgpObSlaves(i),
            -- Trigger Event streams (axilClk domain)
            trigMaster      => trigMasters(i),
            trigSlave       => trigSlaves(i),
            -- DMA Interface (dmaClk domain)
            dmaClk          => dmaClk,
            dmaRst          => dmaRst,
            dmaIbMaster     => dmaIbMasters(i),
            dmaIbSlave      => dmaIbSlaves(i),
            dmaObMaster     => dmaObMasters(i),
            dmaObSlave      => dmaObSlaves(i),
            -- AXI MEM Interface (axilClk domain)
            axiOffset       => AXI_OFFSET_C(i),
            axiWriteMasters => axiWriteMasters(2*i+1 downto 2*i),
            axiWriteSlaves  => axiWriteSlaves(2*i+1 downto 2*i),
            axiReadMasters  => axiReadMasters(2*i+1 downto 2*i),
            axiReadSlaves   => axiReadSlaves(2*i+1 downto 2*i));
   end generate GEN_VEC;

end mapping;
