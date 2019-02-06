-------------------------------------------------------------------------------
-- File       : StandardImageFormatterFsm.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Module to reorganize camera row data with ability to do 
--              black image subtraction
--
-- Note: With respect to surf/protocols/clink/hdl/ClinkFraming.vhd:
--       Supported: CDM_8BIT_C,  CDM_10BIT_C, CDM_12BIT_C, CDM_14BIT_C, CDM_16BIT_C
--     Unsupported: CDM_24BIT_C, CDM_30BIT_C, CDM_36BIT_C
--
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

entity StandardImageFormatterFsm is
   generic (
      TPD_G            : time := 1 ns;
      AXI_CONFIG_G     : AxiConfigType;
      AXIS_CONFIG_G    : AxiStreamConfigType;
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Row Remapping LUT Interface (axilClk domain)
      axilReq         : out AxiLiteReqType;
      axilAck         : in  AxiLiteAckType;
      row             : out slv(10 downto 0);
      remapRow        : in  slv(10 downto 0);
      -- AXI Stream Interface (axilClk domain)
      sAxisMaster     : in  AxiStreamMasterType;
      sAxisSlave      : out AxiStreamSlaveType;
      mAxisMaster     : out AxiStreamMasterType;
      mAxisSlave      : in  AxiStreamSlaveType;
      -- AXI MEM Interface (axilClk domain)
      axiOffset       : in  slv(63 downto 0);  -- Used to apply an address offset to the master AXI transactions
      axiWriteMasters : out AxiWriteMasterArray(1 downto 0);
      axiWriteSlaves  : in  AxiWriteSlaveArray(1 downto 0);
      axiReadMasters  : out AxiReadMasterArray(1 downto 0);
      axiReadSlaves   : in  AxiReadSlaveArray(1 downto 0));
end StandardImageFormatterFsm;

architecture rtl of StandardImageFormatterFsm is

   constant MAX_IMAGE_SIZE_C : positive := 2**24;  -- in units of bytes (4096 pixels x 4096 pixels) = 2^24
   constant NUM_BUFF_C       : positive := 2**(AXI_CONFIG_G.ADDR_WIDTH_C-24);  -- Number of image buffers

   type InitStateType is (
      REQ_S,
      ACK_S,
      DONE_S);

   type WrStateType is (
      IDLE_S,
      WADDR_S,
      WDATA_S);

   type RdStateType is (
      IDLE_S,
      RADDR_S,
      RDATA_S);

   type RegType is record
      pending          : natural range 0 to NUM_BUFF_C-1;
      -- AXI-Lite Slave end point 
      pixConfig        : sl;
      rowSize          : slv(10 downto 0);
      colSize          : slv(7 downto 0);
      useBlackimage    : sl;
      updateBlackImage : sl;
      axilReadSlave    : AxiLiteReadSlaveType;
      axilWriteSlave   : AxiLiteWriteSlaveType;
      -- Initialization
      initCnt          : natural range 0 to 2047;
      axilReq          : AxiLiteReqType;
      initDone         : sl;
      initState        : InitStateType;
      -- AXI Write Logic
      wrIndex          : natural range 0 to NUM_BUFF_C-2;
      wrRow            : natural range 0 to 2047;
      wrCol            : natural range 0 to 255;
      wrRowSize        : slv(10 downto 0);
      wrColSize        : slv(7 downto 0);
      wrBlackImage     : sl;
      sAxisSlave       : AxiStreamSlaveType;
      axiWriteMasters  : AxiWriteMasterArray(1 downto 0);
      wrState          : WrStateType;
      -- AXI read Logic
      rdIndex          : natural range 0 to NUM_BUFF_C-2;
      rdRowSize        : slv(10 downto 0);
      rdColSize        : slv(7 downto 0);
      rdRow            : natural range 0 to 2047;
      rdCol            : natural range 0 to 255;
      rdBlackImage     : sl;
      mAxisMaster      : AxiStreamMasterType;
      axiReadMasters   : AxiReadMasterArray(1 downto 0);
      rdState          : RdStateType;
   end record;

   constant REG_INIT_C : RegType := (
      pending          => 0,
      -- AXI-Lite Slave end point 
      pixConfig        => '1',
      rowSize          => (others => '1'),
      colSize          => (others => '1'),
      useBlackimage    => '0',
      updateBlackImage => '0',
      axilReadSlave    => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave   => AXI_LITE_WRITE_SLAVE_INIT_C,
      -- Initialization
      initCnt          => 0,
      axilReq          => AXI_LITE_REQ_INIT_C,
      initDone         => '0',
      initState        => REQ_S,
      -- AXI Write Logic
      wrIndex          => 0,
      wrRowSize        => (others => '1'),
      wrColSize        => (others => '1'),
      wrRow            => 0,
      wrCol            => 0,
      wrBlackImage     => '0',
      sAxisSlave       => AXI_STREAM_SLAVE_INIT_C,
      axiWriteMasters  => (others => axiWriteMasterInit(AXI_CONFIG_G, '1', "01", "1111")),
      wrState          => IDLE_S,
      -- AXI read Logic
      rdIndex          => 0,
      rdRowSize        => (others => '1'),
      rdColSize        => (others => '1'),
      rdRow            => 0,
      rdCol            => 0,
      rdBlackImage     => '0',
      mAxisMaster      => AXI_STREAM_MASTER_INIT_C,
      axiReadMasters   => (others => axiReadMasterInit(AXI_CONFIG_G, "01", "1111")),
      rdState          => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axiOffset, axiReadSlaves, axiWriteSlaves, axilAck,
                   axilReadMaster, axilRst, axilWriteMaster, mAxisSlave, r,
                   remapRow, sAxisMaster) is
      variable v        : RegType;
      variable axilEp   : AxiLiteEndpointType;
      variable i        : natural;
      variable remapIdx : natural;
   begin
      -- Latch the current value
      v := r;

      -- Update variable
      remapIdx := conv_integer(remapRow);

      -- AXI flow control
      for i in 1 downto 0 loop

         if axiWriteSlaves(i).awready = '1' then
            v.axiWriteMasters(i).awvalid := '0';
         end if;

         v.axiWriteMasters(i).wstrb := (others => '1');
         if axiWriteSlaves(i).wready = '1' then
            v.axiWriteMasters(i).wvalid := '0';
            v.axiWriteMasters(i).wlast  := '0';
         end if;

         v.axiReadMasters(i).rready := '0';
         if axiReadSlaves(i).arready = '1' then
            v.axiReadMasters(i).arvalid := '0';
         end if;

      end loop;

      -- AXI stream flow control
      v.sAxisSlave.tReady := '0';
      if (mAxisSlave.tReady = '1') then
         v.mAxisMaster.tValid := '0';
         v.mAxisMaster.tLast  := '0';
         v.mAxisMaster.tUser  := (others => '0');
      end if;

      -------------------------------------------------------------------------
      --                         AXI-Lite Transaction
      -------------------------------------------------------------------------

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"00", 0, v.pixConfig);  -- '0' = 1byte per pixel, '1' = 2byte per pixel, 
      axiSlaveRegister(axilEp, x"04", 0, v.rowSize);  -- Number of (128-bit words per row) minus one
      axiSlaveRegister(axilEp, x"08", 0, v.colSize);  -- Number of (128-bit words per column) minus one
      axiSlaveRegister(axilEp, x"0C", 0, v.useBlackimage);  -- '0' = send raw data, '1' = send black image subtracted
      axiSlaveRegister(axilEp, x"10", 0, v.updateBlackImage);  -- Command to log black image in memory

      -- Close out the Transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -------------------------------------------------------------------------
      --                      Initialization State Machine
      -------------------------------------------------------------------------
      case (r.initState) is
         ----------------------------------------------------------------------
         when REQ_S =>
            -- Check if transaction completed
            if (axilAck.done = '0') then

               -- Setup the AXI-Lite Master request
               v.axilReq.request := '1';
               v.axilReq.rnw     := '0';                   -- Write operation
               v.axilReq.address := AXIL_BASE_ADDR_G + toSlv((4*r.initCnt), 32);
               v.axilReq.wrData  := toSlv(r.initCnt, 32);  -- Initialization LUT RAM to standard ordering

               -- Next state
               v.initState := ACK_S;

            end if;
         ----------------------------------------------------------------------
         when ACK_S =>
            -- Wait for DONE to set
            if (axilAck.done = '1') then

               -- Reset the flag
               v.axilReq.request := '0';

               -- Check for last transfer
               if (r.initCnt = 2047) then

                  -- Reset the counter
                  v.initCnt := 0;

                  -- Next state
                  v.initState := DONE_S;

               else

                  -- Increment the counter
                  v.initCnt := r.initCnt + 1;

                  -- Next state
                  v.initState := REQ_S;

               end if;

            end if;
         ----------------------------------------------------------------------
         when DONE_S =>
            v.initDone := '1';
      ----------------------------------------------------------------------
      end case;

      -------------------------------------------------------------------------
      --                      AXI Write State Machine
      -------------------------------------------------------------------------
      case (r.wrState) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset signals
            v.wrRow        := 0;
            v.wrCol        := 0;
            v.wrBlackImage := '0';

            -- Wait for Initialization to be done 
            if (r.initDone = '1') then

               -- New inbound AXIS frame
               if (sAxisMaster.tValid = '1') then

                  -- Check for SOF
                  if (ssiGetUserSof(AXIS_CONFIG_G, sAxisMaster) = '1') then

                     -- Make local copy in case configuration change during transfer
                     v.wrColSize := r.colSize;
                     v.wrRowSize := r.rowSize;

                     -- Check if armed to take a black image
                     if (r.updateBlackImage = '1') then

                        -- Set the flag
                        v.wrBlackImage := '1';

                        -- Check if read pending is empty
                        if (r.pending = 0) then

                           -- Reset the flag
                           v.updateBlackImage := '0';

                           -- Next State
                           v.wrState := WADDR_S;

                        end if;

                     -- Check if room in pending queue
                     elsif (r.pending /= (NUM_BUFF_C-1)) then

                        -- Next State
                        v.wrState := WADDR_S;
                     end if;

                  else
                     -- Blow off the misaligned data
                     v.sAxisSlave.tReady := '1';

                  end if;

               end if;
            end if;
         ----------------------------------------------------------------------
         when WADDR_S =>
            -- Check if ready to preform write transaction
            if (v.axiWriteMasters(0).awvalid = '0') and (v.axiWriteMasters(1).awvalid = '0') then

               -- Write Address data channel
               v.axiWriteMasters(0).awvalid := '1';
               v.axiWriteMasters(0).awaddr  := toSlv((MAX_IMAGE_SIZE_C*r.wrIndex) + (4096*remapIdx), 64);

               -- Write Address black image channel
               v.axiWriteMasters(1).awvalid := r.wrBlackImage;
               v.axiWriteMasters(1).awaddr  := toSlv((MAX_IMAGE_SIZE_C*(NUM_BUFF_C-1)) + (4096*remapIdx), 64);

               -- Next State
               v.wrState := WDATA_S;

            end if;
         ----------------------------------------------------------------------
         when WDATA_S =>
            -- Check if data available (assuming pack/forward FIFO in AXI interconnect module)
            if (v.axiWriteMasters(0).wvalid = '0') and (v.axiWriteMasters(1).wvalid = '0') and (sAxisMaster.tValid = '1') then

               -- Write data channel
               v.axiWriteMasters(0).wvalid              := '1';
               v.axiWriteMasters(0).wdata(127 downto 0) := sAxisMaster.tData(127 downto 0);

               -- Write black image channel
               v.axiWriteMasters(1).wvalid              := r.wrBlackImage;
               v.axiWriteMasters(1).wdata(127 downto 0) := sAxisMaster.tData(127 downto 0);

               -- Increment the counter
               v.wrCol := r.wrCol + 1;

               -- Check if forwarding the 
               if (r.wrCol <= r.colSize) then

                  -- Accept the data
                  v.sAxisSlave.tReady := '1';

               end if;

               -- Check for end of 4kB transfer (128-bit x 256)
               if (r.wrCol = 255) then

                  -- Reset the counter
                  v.wrCol := 0;

                  -- Set the flags
                  v.axiWriteMasters(0).wlast := '1';
                  v.axiWriteMasters(1).wlast := '1';

                  -- Check for the last row
                  if (r.wrRow = r.wrRowSize) then

                     -- Reset the counter
                     v.wrRow := 0;

                     -- Check for index roll over    
                     if (r.wrIndex = NUM_BUFF_C-2) then
                        -- Reset the counter
                        v.wrIndex := 0;
                     else
                        -- Increment the counter
                        v.wrIndex := r.wrIndex + 1;
                     end if;

                     -- Increment the pending counter
                     if (r.pending /= (NUM_BUFF_C-1)) then
                        v.pending := r.pending + 1;
                     end if;

                     -- Next State
                     v.wrState := IDLE_S;

                  else

                     -- Increment the counter
                     v.wrRow := r.wrRow + 1;

                     -- Next State
                     v.wrState := WADDR_S;

                  end if;
               end if;
            end if;
      ----------------------------------------------------------------------
      end case;

      -------------------------------------------------------------------------
      --                      AXI Read State Machine
      -------------------------------------------------------------------------
      case (r.rdState) is
         when IDLE_S =>
            -- Reset signals
            v.rdRow := 0;
            v.rdCol := 0;

            -- Make local copy in case configuration change during transfer
            v.rdColSize    := r.colSize;
            v.rdRowSize    := r.rowSize;
            v.rdBlackImage := r.useBlackimage;

            -- Check if there a pending read
            if (r.pending /= 0) then
               -- Next State
               v.rdState := RADDR_S;
            end if;
         ----------------------------------------------------------------------
         when RADDR_S =>
            -- Check if ready to preform read transaction
            if (v.axiReadMasters(0).arvalid = '0') and (v.axiReadMasters(1).arvalid = '0') then

               -- Read Address data channel
               v.axiReadMasters(0).arvalid := '1';
               v.axiReadMasters(0).araddr  := toSlv((MAX_IMAGE_SIZE_C*r.rdIndex) + (4096*r.rdRow), 64);

               -- Read Address black image channel
               v.axiReadMasters(1).arvalid := r.rdBlackImage;
               v.axiReadMasters(1).araddr  := toSlv((MAX_IMAGE_SIZE_C*(NUM_BUFF_C-1)) + (4096*r.rdRow), 64);

               -- Next State
               v.rdState := RDATA_S;

            end if;
         ----------------------------------------------------------------------
         when RDATA_S =>
            -- Check if data available (assuming pack/forward FIFO in AXI interconnect module) 
            if (axiReadSlaves(0).rvalid = '1') and (axiReadSlaves(1).rvalid = '1') and (v.mAxisMaster.tValid = '0') then

               -- Accept the data
               v.axiReadMasters(0).rready := '1';
               v.axiReadMasters(1).rready := '1';

               -- Increment the counter
               v.rdCol := r.rdCol + 1;

               -- Check if forwarding the 
               if (r.rdCol <= r.rdColSize) then

                  -- Move the data
                  v.mAxisMaster.tValid := '1';

                  -- Check for SOF condition
                  if (r.rdRow = 0) and (r.rdCol = 0) then
                     -- Insert the SOF bit
                     ssiSetUserSof(AXIS_CONFIG_G, v.mAxisMaster, '1');
                  end if;

                  -- Check for EOF condition
                  if (r.rdRow = r.rdRowSize) and (r.rdCol = r.rdColSize) then
                     -- Insert the EOF bit
                     v.mAxisMaster.tLast := '1';
                  end if;

                  -- Check if sending raw image
                  if (r.rdBlackImage = '0') then
                     -- Send the raw data
                     v.mAxisMaster.tData(127 downto 0) := axiReadSlaves(0).rdata(127 downto 0);
                  else

                     -- TODO: add black image subtraction here
                     v.mAxisMaster.tData(127 downto 0) := axiReadSlaves(0).rdata(127 downto 0);

                  end if;

               end if;

               -- Check for end of 4kB transfer
               if (axiReadSlaves(0).rlast = '1') then

                  -- Reset the counter
                  v.rdCol := 0;

                  -- Check for the last row
                  if (r.rdRow = r.rdRowSize) then

                     -- Reset the counter
                     v.rdRow := 0;

                     -- Check for index roll over    
                     if (r.rdIndex = NUM_BUFF_C-2) then
                        -- Reset the counter
                        v.rdIndex := 0;
                     else
                        -- Increment the counter
                        v.rdIndex := r.rdIndex + 1;
                     end if;

                     -- Decrement the pending counter
                     if (v.pending /= 0) then
                        v.pending := v.pending - 1;
                     end if;

                     -- Next State
                     v.rdState := IDLE_S;

                  else

                     -- Increment the counter
                     v.rdRow := r.rdRow + 1;

                     -- Next State
                     v.rdState := RADDR_S;

                  end if;
               end if;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Outputs
      axilReq <= r.axilReq;
      row     <= toSlv(v.wrRow, 11);

      sAxisSlave  <= v.sAxisSlave;
      mAxisMaster <= r.mAxisMaster;

      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;

      axiWriteMasters <= r.axiWriteMasters;
      axiReadMasters  <= r.axiReadMasters;

      for i in 1 downto 0 loop

         axiWriteMasters(i).bready <= v.axiWriteMasters(i).bready;
         axiWriteMasters(i).awaddr <= r.axiWriteMasters(i).awaddr + axiOffset;

         axiReadMasters(i).rready <= v.axiReadMasters(i).rready;
         axiReadMasters(i).araddr <= r.axiReadMasters(i).araddr + axiOffset;

      end loop;

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

end rtl;
