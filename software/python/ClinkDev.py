#!/usr/bin/env python3
import pyrogue as pr
import rogue.hardware.axi
import rogue.protocols

import surf.axi             as axiVer
import surf.xilinx          as xil
import surf.devices.micron  as prom
import surf.devices.linear  as linear
import surf.devices.nxp     as nxp
import surf.protocols.clink as cl

import time

class ClTestRx(rogue.interfaces.stream.Slave):

    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)
        self._count = 0
        self._lerr = 0
        self._derr = 0
        self._ltm = int(time.time())

    def _acceptFrame(self,frame):
        p = bytearray(frame.getPayload())
        frame.read(p,0)
        self._count += 1

        if len(p) != 2048:
            self._lerr += 1

        for i in range(len(p)):
            exp = i & 0xFF
            if p[i] != exp:
                self._derr += 1
                #print("Mismatch in frame {} position {}. Got = {:#x}, Exp = {:#x}".format(self._count,i,p[i],exp))

        ctm = int(time.time())
        if ctm != self._ltm:
            self._ltm = ctm
            print("Frame count: {}, Length errors: {}, Data Errors: {}".format(self._count,self._lerr,self._derr))

            
class ClinkTrigCtrl(pr.Device):
    def __init__(   self,       
            name        = "ClinkTrigCtrl",
            description = "Trigger Controller Container",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs) 

        ##############################
        # Variables
        ##############################
        self.add(pr.RemoteVariable(    
            name         = "EnableTrig",
            description  = "Enable triggering",
            offset       = 0x000,
            bitSize      = 1,
            base         = pr.Bool,
            mode         = "RW",
        ))   

        self.add(pr.RemoteVariable(    
            name         = "InvCC",
            description  = "Inverter the 4-bit camCtrl bus",
            offset       = 0x004,
            bitSize      = 1,
            base         = pr.Bool,
            mode         = "RW",
        ))    

        self.add(pr.RemoteVariable(    
            name         = "TrigMap",
            description  = "0x0: map trigger to channel A, 0x1: map trigger to channel B",
            offset       = 0x008,
            bitSize      = 1,
            mode         = "RW",
            enum         = {
                0x0: 'ChA', 
                0x1: 'ChB', 
            },            
        ))

        self.add(pr.RemoteVariable(    
            name         = "TrigPulseWidth",
            description  = "Sets the trigger pulse width on the 4-bit camCtrl bus",
            offset       = 0x00C,
            bitSize      = 16,
            mode         = "RW",
            units        = '1/125MHz',          
        ))     

        self.add(pr.RemoteVariable(    
            name         = "TrigMask",
            description  = "Sets the trigger mask on the 4-bit camCtrl bus",
            offset       = 0x010,
            bitSize      = 4,
            mode         = "RW",
        ))             
            
class ClinkDev(pr.Root):

    def __init__(self):

        pr.Root.__init__(self,name='ClinkDev',description='CameraLink Dev')

        # Create the stream interface
        #self._pgpVc0 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,0) # Registers
        #self._pgpVc1 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,1) # Data
        #self._pgpVc2 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,2) # Serial
        #self._pgpVc3 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,3) # Serial

        self._pgpVc0 = rogue.hardware.axi.AxiStreamDma('/dev/datadev_0',0,True) # Registers
        self._pgpVc1 = rogue.hardware.axi.AxiStreamDma('/dev/datadev_0',1,True) # Data
        self._pgpVc2 = rogue.hardware.axi.AxiStreamDma('/dev/datadev_0',2,True) # Serial
        self._pgpVc3 = rogue.hardware.axi.AxiStreamDma('/dev/datadev_0',3,True) # Serial

        # SRP
        self._srp = rogue.protocols.srp.SrpV3()
        pr.streamConnectBiDir(self._pgpVc0,self._srp)

        
        # Add devices
        self.add(axiVer.AxiVersion( 
            name        = 'AxiVersion', 
            memBase     = self._srp, 
            offset      = 0x00000000, 
            expand      = False,
        ))
        
        self.add(prom.AxiMicronN25Q(
            name        = 'AxiMicronN25Q', 
            memBase     = self._srp, 
            offset      = 0x00001000, 
            hidden      = True, # Hidden in GUI because indented for scripting
        ))
        
        self.add(nxp.Sa56004x(      
            name        = 'BoardTemp', 
            description = 'This device monitors the board temperature and FPGA junction temperature', 
            memBase     = self._srp, 
            offset      = 0x00002000, 
            expand      = False,
        ))
        
        self.add(linear.Ltc4151(
            name        = 'BoardPwr', 
            description = 'This device monitors the board power, input voltage and input current', 
            memBase     = self._srp, 
            offset      = 0x00002400, 
            senseRes    = 20.E-3, # Units of Ohms
            expand      = False,
        ))
        
        self.add(xil.Xadc(
            name        = 'Xadc', 
            memBase     = self._srp,
            offset      = 0x00003000, 
            expand      = False,
        ))        
        
        self.add(cl.ClinkTop(
            memBase     = self._srp,
            offset      = 0x00010000,
            serialA     = self._pgpVc2,
            serialB     = self._pgpVc3
        ))

        self.add(ClinkTrigCtrl(      
            name        = 'TrigCtrl[0]', 
            description = 'Channel A trigger control', 
            memBase     = self._srp, 
            offset      = 0x00020000, 
            expand      = False,
        )) 

        self.add(ClinkTrigCtrl(      
            name        = 'TrigCtrl[1]', 
            description = 'Channel B trigger control', 
            memBase     = self._srp, 
            offset      = 0x00020100, 
            expand      = False,
        ))         
        
        # Debug slave
        self._dbg = ClTestRx()
        pr.streamConnect(self._pgpVc1,self._dbg)

        # Start the system
        self.start(pollEn=False)
        