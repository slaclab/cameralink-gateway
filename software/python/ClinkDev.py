#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'Camera link gateway'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'Camera link gateway', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue as pr

import rogue.hardware.axi
import rogue.protocols
import pyrogue.interfaces.simulation

import XilinxKcu1500Pgp as kcu1500
import ClinkFeb         as feb
import Application      as app

import time

class ClinkDev(pr.Root):

    def __init__(self,
            name        = 'ClinkDev',
            description = 'Container for CameraLink Dev',
            dev         = '/dev/datadev_0',# path to PCIe device
            version3    = False,           # true = PGPv3, false = PGP2b
            pollEn      = True,            # Enable automatic polling registers
            initRead    = True,            # Read all registers at start of the system
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        # Create PCIE memory mapped interface
        if (dev != 'sim'):
            # BAR0 access
            self.memMap = rogue.hardware.axi.AxiMemMap(dev)     
            # Set the timeout
            self._timeout = 1.0 # 1.0 default
        else:
            # FW/SW co-simulation
            self.memMap = rogue.interfaces.memory.TcpClient('localhost',8000)            
            # Set the timeout
            self._timeout = 100.0 # firmware simulation slow and timeout base on real time (not simulation time)

        # PGP Application on PCIe 
        self.add(app.Application(            
            memBase  = self.memMap,
            numLane  = 4,
            expand   = False,
        ))
            
        # PGP Hardware on PCIe 
        self.add(kcu1500.Hardware(            
            memBase  = self.memMap,
            numLane  = 4,
            version3 = version3,
            # expand   = False,
        ))   

        # Create arrays to be filled
        self._dma = [[None for vc in range(4)] for lane in range(4)] # self._dma[lane][vc]
        self._srp =  [None for lane in range(4)]
        
        # Create the stream interface
        for lane in range(4):
        
            # Map the virtual channels 
            if (dev != 'sim'):
                # PCIe DMA interface
                self._dma[lane][0] = rogue.hardware.axi.AxiStreamDma(dev,(0x100*lane)+0,True) # VC0 = Registers
                self._dma[lane][1] = rogue.hardware.axi.AxiStreamDma(dev,(0x100*lane)+1,True) # VC1 = Data
                self._dma[lane][2] = rogue.hardware.axi.AxiStreamDma(dev,(0x100*lane)+2,True) # VC2 = Serial
                self._dma[lane][3] = rogue.hardware.axi.AxiStreamDma(dev,(0x100*lane)+3,True) # VC3 = Serial
            else:
                # FW/SW co-simulation
                self._dma[lane][0] = rogue.interfaces.stream.TcpClient('localhost',8002+(512*lane)+2*0,True) # VC0 = Registers
                self._dma[lane][1] = rogue.interfaces.stream.TcpClient('localhost',8002+(512*lane)+2*1,True) # VC1 = Data
                self._dma[lane][2] = rogue.interfaces.stream.TcpClient('localhost',8002+(512*lane)+2*2,True) # VC2 = Serial
                self._dma[lane][3] = rogue.interfaces.stream.TcpClient('localhost',8002+(512*lane)+2*3,True) # VC3 = Serial
                
            # Disabling zero copy on the data stream
            self._dma[lane][1].setZeroCopyEn(False)    
                
            # SRP
            self._srp[lane] = rogue.protocols.srp.SrpV3()
            pr.streamConnectBiDir(self._dma[lane][0],self._srp[lane])
                     
            # CameraLink Feb Board
            self.add(feb.ClinkFeb(      
                name        = (f'ClinkFeb[{lane}]'), 
                memBase     = self._srp[lane], 
                serialA     = self._dma[lane][2],
                serialB     = self._dma[lane][3],
                camTypeA    = 'Opal000', # Assuming OPA 1000 camera
                camTypeB    = 'Opal000', # Assuming OPA 1000 camera
                version3    = version3,
                enableDeps  = [self.Hardware.PgpMon[lane].RxRemLinkReady], # Only allow access if the PGP link is established
                expand      = False,
            ))         
        
        # Start the system
        self.start(
            pollEn   = pollEn,
            initRead = initRead,
            timeout  = self._timeout,
        )
        