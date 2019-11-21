-------------------------------------------------------------------------------
-- File       : ClinkFebPgp2b_1ch.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Camera link gateway FEB with PGPv2b and 1 CLink channels
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


library surf;
use surf.StdRtlPkg.all;

library clink_gateway_fw_lib; 

entity ClinkFebPgp2b_1ch is
   generic (
      TPD_G        : time    := 1 ns;
      BUILD_INFO_G : BuildInfoType;
      SIMULATION_G : boolean := false);
   port (
      -- Clink Ports
      cbl0Half0P    : inout slv(4 downto 0);  --  2,  4,  5,  6, 3
      cbl0Half0M    : inout slv(4 downto 0);  -- 15, 17, 18, 19 16
      cbl0Half1P    : inout slv(4 downto 0);  --  8, 10, 11, 12,  9
      cbl0Half1M    : inout slv(4 downto 0);  -- 21, 23, 24, 25, 22
      cbl0SerP      : out   sl;               -- 20
      cbl0SerM      : out   sl;               -- 7
      cbl1Half0P    : inout slv(4 downto 0);  --  2,  4,  5,  6, 3
      cbl1Half0M    : inout slv(4 downto 0);  -- 15, 17, 18, 19 16
      cbl1Half1P    : inout slv(4 downto 0);  --  8, 10, 11, 12,  9
      cbl1Half1M    : inout slv(4 downto 0);  -- 21, 23, 24, 25, 22
      cbl1SerP      : out   sl;               -- 20
      cbl1SerM      : out   sl;               -- 7
      -- LEDs
      ledRed        : out   slv(1 downto 0);
      ledGrn        : out   slv(1 downto 0);
      ledBlu        : out   slv(1 downto 0);
      -- Boot Memory Ports
      bootCsL       : out   sl;
      bootMosi      : out   sl;
      bootMiso      : in    sl;
      -- Timing GPIO Ports
      timingClkSel  : out   sl;
      timingXbarSel : out   slv(3 downto 0);
      -- GTX Ports
      gtClkP        : in    slv(1 downto 0);
      gtClkN        : in    slv(1 downto 0);
      gtRxP         : in    slv(3 downto 0);
      gtRxN         : in    slv(3 downto 0);
      gtTxP         : out   slv(3 downto 0);
      gtTxN         : out   slv(3 downto 0);
      -- SFP Ports
      sfpScl        : inout slv(3 downto 0);
      sfpSda        : inout slv(3 downto 0);
      -- Misc Ports
      pwrScl        : inout sl;
      pwrSda        : inout sl;
      configScl     : inout sl;
      configSda     : inout sl;
      fdSerSdio     : inout sl;
      tempAlertL    : in    sl;
      vPIn          : in    sl;
      vNIn          : in    sl);
end ClinkFebPgp2b_1ch;

architecture top_level of ClinkFebPgp2b_1ch is

begin

   U_Core : entity clink_gateway_fw_lib.CLinkGateway
      generic map (
         TPD_G        => TPD_G,
         CHAN_COUNT_G => 1,             -- One CLink channel
         PGP_TYPE_G   => false,         -- False: PGPv2b@3.125Gb/s
         BUILD_INFO_G => BUILD_INFO_G,
         SIMULATION_G => SIMULATION_G)
      port map (
         -- Clink Ports
         cbl0Half0P    => cbl0Half0P,
         cbl0Half0M    => cbl0Half0M,
         cbl0Half1P    => cbl0Half1P,
         cbl0Half1M    => cbl0Half1M,
         cbl0SerP      => cbl0SerP,
         cbl0SerM      => cbl0SerM,
         cbl1Half0P    => cbl1Half0P,
         cbl1Half0M    => cbl1Half0M,
         cbl1Half1P    => cbl1Half1P,
         cbl1Half1M    => cbl1Half1M,
         cbl1SerP      => cbl1SerP,
         cbl1SerM      => cbl1SerM,
         -- LEDs
         ledRed        => ledRed,
         ledGrn        => ledGrn,
         ledBlu        => ledBlu,
         -- Boot Memory Ports
         bootCsL       => bootCsL,
         bootMosi      => bootMosi,
         bootMiso      => bootMiso,
         -- Timing GPIO Ports
         timingClkSel  => timingClkSel,
         timingXbarSel => timingXbarSel,
         -- GTX Ports
         gtClkP        => gtClkP,
         gtClkN        => gtClkN,
         gtRxP         => gtRxP,
         gtRxN         => gtRxN,
         gtTxP         => gtTxP,
         gtTxN         => gtTxN,
         -- SFP Ports
         sfpScl        => sfpScl,
         sfpSda        => sfpSda,
         -- Misc Ports
         pwrScl        => pwrScl,
         pwrSda        => pwrSda,
         configScl     => configScl,
         configSda     => configSda,
         fdSerSdio     => fdSerSdio,
         tempAlertL    => tempAlertL,
         vPIn          => vPIn,
         vNIn          => vNIn);

end top_level;
