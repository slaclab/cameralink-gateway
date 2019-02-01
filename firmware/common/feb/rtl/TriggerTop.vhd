-------------------------------------------------------------------------------
-- File       : TriggerTop.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top Trigger Module
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity TriggerTop is
   generic (
      TPD_G           : time             := 1 ns;
      SIMULATION_G    : boolean          := false;
      AXI_BASE_ADDR_G : slv(31 downto 0) := (others => '0'));
   port (
      -- Trigger Interface
      pgpTrigger      : in  slv(1 downto 0);
      camCtrl         : out Slv4Array(1 downto 0);
      -- Axi-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Timing GPIO Ports
      timingClkSel    : out sl;
      timingXbarSel   : out slv(3 downto 0);
      -- Timing RX Ports
      timingClkP      : in  sl;
      timingClkN      : in  sl;
      timingRxP       : in  slv(1 downto 0);
      timingRxN       : in  slv(1 downto 0);
      timingTxP       : out slv(1 downto 0);
      timingTxN       : out slv(1 downto 0));
end TriggerTop;

architecture mapping of TriggerTop is

   type RegType is record
      enable         : slv(1 downto 0);
      inv            : slv(1 downto 0);
      trigMap        : slv(1 downto 0);
      ccCntSize      : Slv16Array(1 downto 0);
      ccCount        : Slv16Array(1 downto 0);
      ccTrigMask     : Slv4Array(1 downto 0);
      camCtrl        : Slv4Array(1 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      enable         => "00",
      inv            => "00",
      trigMap        => "10",
      ccCntSize      => (others => toSlv(4095, 16)),
      ccCount        => (others => (others => '0')),
      ccTrigMask     => (others => "0001"),
      camCtrl        => (others => "0000"),
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal timingClkDiv2 : sl;
   signal timingClk     : sl;

begin

   timingClkSel  <= '0';
   timingXbarSel <= x"0";

   U_IBUFDS_GTE2 : IBUFDS_GTE2
      port map (
         I     => timingClkP,
         IB    => timingClkN,
         CEB   => '0',
         ODIV2 => timingClkDiv2,
         O     => timingClk);

   U_TerminateGtx : entity work.Gtxe2ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         refClk => timingClkDiv2,
         gtRxP  => timingRxP,
         gtRxN  => timingRxN,
         gtTxP  => timingTxP,
         gtTxN  => timingTxN);

   comb : process (axilReadMaster, axilRst, axilWriteMaster, pgpTrigger, r) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
      variable trig   : slv(1 downto 0);
   begin
      -- Latch the current value
      v := r;

      ------------------------      
      -- AXI-Lite Transactions
      ------------------------      

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"000", 0, v.enable(0));
      axiSlaveRegister(axilEp, x"004", 0, v.inv(0));
      axiSlaveRegister(axilEp, x"008", 0, v.trigMap(0));
      axiSlaveRegister(axilEp, x"00C", 0, v.ccCntSize(0));
      axiSlaveRegister(axilEp, x"010", 0, v.ccTrigMask(0));

      axiSlaveRegister(axilEp, x"100", 0, v.enable(1));
      axiSlaveRegister(axilEp, x"104", 0, v.inv(1));
      axiSlaveRegister(axilEp, x"108", 0, v.trigMap(1));
      axiSlaveRegister(axilEp, x"10C", 0, v.ccCntSize(1));
      axiSlaveRegister(axilEp, x"110", 0, v.ccTrigMask(1));

      -- Close out the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      for i in 1 downto 0 loop

         -- Map the trigger bit
         if r.trigMap(i) = '0' then
            trig(i) := pgpTrigger(0);
         else
            trig(i) := pgpTrigger(1);
         end if;

         -- Check for PGP trigger and enabled 
         if (trig(i) = '1') and (r.enable(i) = '1') then
            -- Set the counter size
            v.ccCount(i) := r.ccCntSize(i);
            -- Set the flags
            v.camCtrl(i) := r.ccTrigMask(i);

         -- Check for timeout
         elsif (r.ccCount(i) = 0) then
            -- Reset the flags
            v.camCtrl(i) := x"0";
         else

            -- Decrement the counter
            v.ccCount(i) := r.ccCount(i) - 1;
         end if;

         -- Outputs 
         if (r.inv(i) = '0') then
            camCtrl(i) <= r.camCtrl(i);
         else
            camCtrl(i) <= not(r.camCtrl(i));
         end if;

      end loop;

      -- Outputs 
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;

      -- Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
