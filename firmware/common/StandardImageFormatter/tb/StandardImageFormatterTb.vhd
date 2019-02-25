-------------------------------------------------------------------------------
-- File       : StandardImageFormatterTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the StandardImageFormatterTb module
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AppPkg.all;
use work.MigPkg.all;

entity StandardImageFormatterTb is end StandardImageFormatterTb;

architecture testbed of StandardImageFormatterTb is

   constant CLK_PERIOD_G : time := 10 ns;
   constant TPD_G        : time := CLK_PERIOD_G/4;
   
   constant DDR_WIDTH_C : positive := 72;
   
   component Ddr4ModelWrapper
      generic (
         DDR_WIDTH_G : integer);
      port (
         c0_ddr4_dq       : inout slv(DDR_WIDTH_C-1 downto 0);
         c0_ddr4_dqs_c    : inout slv((DDR_WIDTH_C/8)-1 downto 0);
         c0_ddr4_dqs_t    : inout slv((DDR_WIDTH_C/8)-1 downto 0);
         c0_ddr4_adr      : in    slv(16 downto 0);
         c0_ddr4_ba       : in    slv(1 downto 0);
         c0_ddr4_bg       : in    slv(0 to 0);
         c0_ddr4_reset_n  : in    sl;
         c0_ddr4_act_n    : in    sl;
         c0_ddr4_ck_t     : in    slv(0 to 0);
         c0_ddr4_ck_c     : in    slv(0 to 0);
         c0_ddr4_cke      : in    slv(0 to 0);
         c0_ddr4_cs_n     : in    slv(0 to 0);
         c0_ddr4_dm_dbi_n : inout slv((DDR_WIDTH_C/8)-1 downto 0);
         c0_ddr4_odt      : in    slv(0 to 0));
   end component;   

   signal axilClk         : sl                     := '0';
   signal axilRst         : sl                     := '0';
   signal axilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal axilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
   signal axilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal axilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;
   
   signal   axiWriteMasters : AxiWriteMasterArray(7 downto 0) := (others=>AXI_WRITE_MASTER_INIT_C);
   signal   axiWriteSlaves  : AxiWriteSlaveArray(7 downto 0) := (others=>AXI_WRITE_SLAVE_INIT_C);
   signal   axiReadMasters  : AxiReadMasterArray(7 downto 0) := (others=>AXI_READ_MASTER_INIT_C);
   signal   axiReadSlaves   : AxiReadSlaveArray(7 downto 0) := (others=>AXI_READ_SLAVE_INIT_C);

   signal   ddrClk          : sl:= '0';
   signal   ddrRst          : sl:= '0';
   signal   ddrWriteMaster  : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal   ddrWriteSlave   : AxiWriteSlaveType := AXI_WRITE_SLAVE_INIT_C;
   signal   ddrReadMaster   : AxiReadMasterType := AXI_READ_MASTER_INIT_C;
   signal   ddrReadSlave    : AxiReadSlaveType := AXI_READ_SLAVE_INIT_C;
   
   signal   ddrClkP      : sl:= '0';
   signal   ddrClkN      : sl:= '0';
   signal   ddrOut       : DdrOutType;
   signal   ddrInOut     : DdrInOutType;
   
begin

   --------------------
   -- Clocks and Resets
   --------------------
   U_axilClk : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_G,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => axilClk,
         rst  => axilRst);
         
   U_axilClk : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_G,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => ddrClkP,
         clkN  => ddrClkN);         


   -------------------------------------         
   -- Memory Interface Generator IP core
   -------------------------------------         
   U_Mig3 : entity work.Mig3  -- Note: Using MIG[3] because located in FPGA's SLR1 region
      generic map (
         TPD_G => TPD_G)
      port map (
         extRst         => dmaRst,
         -- AXI MEM Interface
         axiClk         => ddrClk,
         axiRst         => ddrRst,
         axiWriteMaster => ddrWriteMaster,
         axiWriteSlave  => ddrWriteSlave,
         axiReadMaster  => ddrReadMaster,
         axiReadSlave   => ddrReadSlave,
         -- DDR Ports
         ddrClkP        => ddrClkP,
         ddrClkN        => ddrClkN,
         ddrOut         => ddrOut,
         ddrInOut       => ddrInOut);
         
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

   ----------------------------------
   -- Standard Image Formatter Module
   ----------------------------------
   U_SIF : entity work.StandardImageFormatter
      generic map (
         TPD_G            => TPD_G,
         AXI_ADDR_WIDTH_C => 30,        -- 2^30 = 1GB buffer
         AXIS_CONFIG_G    => DMA_AXIS_CONFIG_C,
         AXIL_BASE_ADDR_G => x"0000_0000")
      port map (
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- AXI Stream Interface (axilClk domain)
         sAxisMaster     => sAxisMaster,
         sAxisSlave      => sAxisSlave,
         mAxisMaster     => mAxisMaster,
         mAxisSlave      => mAxisSlave,
         -- AXI MEM Interface (axilClk domain)
         axiOffset       => (others=>'0'),
         axiWriteMasters => axiWriteMasters(1 downto 0),
         axiWriteSlaves  => axiWriteSlaves(1 downto 0),
         axiReadMasters  => axiReadMasters(1 downto 0),
         axiReadSlaves   => axiReadSlaves(1 downto 0));


   ---------------------------------
   -- AXI-Lite Register Transactions
   ---------------------------------
   test : process is
   begin

      ------------------------------------------
      -- Wait for the AXI-Lite reset to complete
      ------------------------------------------
      wait until axilRst = '1';
      wait until axilRst = '0';

      axiLiteBusSimWrite (axilClk, axilWriteMaster, axilWriteSlave, x"0000_2000", x"0000_0000", true);  -- '0' = 1byte per pixel, '1' = 2byte per pixel, 
      axiLiteBusSimWrite (axilClk, axilWriteMaster, axilWriteSlave, x"0000_2004", x"0000_0003", true);  -- Number of (128-bit words per row) minus one
      axiLiteBusSimWrite (axilClk, axilWriteMaster, axilWriteSlave, x"0000_2008", x"0000_0003", true);  -- Number of (128-bit words per column) minus one
      axiLiteBusSimWrite (axilClk, axilWriteMaster, axilWriteSlave, x"0000_200C", x"0000_0000", true);  -- '0' = send raw data, '1' = send black image subtracted
      axiLiteBusSimWrite (axilClk, axilWriteMaster, axilWriteSlave, x"0000_2010", x"0000_0000", true);  -- Command to log black image in memory

   end process test;

end testbed;
