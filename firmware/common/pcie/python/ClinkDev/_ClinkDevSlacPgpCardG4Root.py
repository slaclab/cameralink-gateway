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
import pyrogue  as pr
import ClinkDev as clDev

class ClinkDevSlacPgpCardG4Root(clDev.ClinkDevRoot):

    def __init__(self,**kwargs):
        
        # Pass custom value to parent via super function
        super().__init__(
            name         = 'ClinkRoot',
            clDevTarget  = clDev.ClinkDevSlacPgpCardG4,
            numLanes     = 8,            
            **kwargs)
