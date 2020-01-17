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

import axipcie

import lcls2_pgp_fw_lib.hardware.XilinxKcu1500

import ClinkDev

class ClinkDevKcu1500(pr.Device):
    def __init__(self, 
                 numLanes = 4, 
                 pgp3     = False, 
                 **kwargs):
        super().__init__(**kwargs)

        # The time tool application
        self.add(ClinkDev.Application(
            offset   = 0x00C0_0000,
            numLanes = numLanes,
            expand   = True,
        ))
            
        # PGP Hardware on PCIe 
        self.add(lcls2_pgp_fw_lib.hardware.XilinxKcu1500.Kcu1500Hsio( 
            offset    = 0x0080_0000,
            numLanes  = numLanes,
            pgp3      = pgp3,
            expand    = True,
        ))
        
        self.add(axipcie.AxiPcieCore(
            offset      = 0x0000_0000,
            numDmaLanes = numLanes,
            expand      = False,
        ))  
