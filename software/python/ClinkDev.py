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

import rogue.protocols

import XilinxKcu1500Pgp as kcu1500
import ClinkFeb         as feb
import Application      as app

import rogue.interfaces.stream

class MyCustomMaster(rogue.interfaces.stream.Master):

    # Init method must call the parent class init
    def __init__(self):
        super().__init__()

    # Method for generating a frame
    def myFrameGen(self):

        # First request an empty from from the primary slave
        # The first arg is the size, the second arg is a boolean
        # indicating if we can allow zero copy buffers, usually set to true

        # Here we request a frame capable of holding 100 bytes
        frame = self._reqFrame(100, True)

        # Create a 10 byte array with an incrementing value
        ba = bytearray([i for i in range(10)])

        # Write the data to the frame at offset 0
        # The payload size of the frame is automatically updated
        # to the highest index which as written to.
        # A lock is not required because we are the only instance
        # which knows about this frame at this point

        # The frame will now have a payload size of 10
        frame.write(ba,0)

        # The user may also write to an arbitrary offset, the valid payload
        # size of the frame is set to the highest index written.
        # Locations not explicity written, but below the highest written
        # index, will be considered valid, but may contain random data
        ba = bytearray([i*2 for i in range(10)])
        frame.write(ba,50)

        # At this point locations 0 - 9 and 50 - 59 contain known values
        # The new payload size is now 60, but locations 10 - 49 may
        # contain random data

        # Send the frame to the currently attached slaves
        # The method returns once all the slaves have received the
        # frame and their acceptFrame methods have returned
        self._sendFrame(frame)

class ClinkDev(kcu1500.Core):

    def __init__(self,
            name        = 'ClinkDev',
            description = 'Container for CameraLink Dev',
            dev         = '/dev/datadev_0',# path to PCIe device
            version3    = False,           # true = PGPv3, false = PGP2b
            pollEn      = True,            # Enable automatic polling registers
            initRead    = True,            # Read all registers at start of the system
            numLane     = 4,               # Number of PGP lanes
            **kwargs
        ):
        super().__init__(
            name        = name, 
            description = description, 
            dev         = dev, 
            version3    = version3, 
            numLane     = numLane, 
            **kwargs
        )
        
        # PGP Application on PCIe 
        self.add(app.Application(
            memBase  = self._memMap,
            numLane  = numLane,
            expand   = False,
        ))

        # Check if not doing simulation
        if (dev != 'sim'):
            
            # Create arrays to be filled
            self._srp = [None for lane in range(numLane)]
            
            # Create the stream interface
            for lane in range(numLane):
                            
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
                
        # Else doing Rogue VCS simulation
        else:
        
            # Create arrays to be filled
            self._frameGen = [None for lane in range(numLane)]
            
            # Create the stream interface
            for lane in range(numLane):        
            
                # Create the frame generator
                self._frameGen[lane] = MyCustomMaster()
                
                # Connect the frame generator
                pr.streamConnect(self._frameGen[lane],self._pgp[lane][1]) 
                    
                # Create a command to execute the frame generator
                self.add(pr.BaseCommand(   
                    name         = f'GenFrame[{lane}]',
                    function     = lambda cmd: self._frameGen[lane].myFrameGen(),
                ))
                
        # Start the system
        self.start(
            pollEn   = pollEn,
            initRead = initRead,
            timeout  = self._timeout,
        )
        