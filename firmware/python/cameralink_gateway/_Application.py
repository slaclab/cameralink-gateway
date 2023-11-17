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

import surf.protocols.batcher as batcher

class AppLane(pr.Device):
    def __init__(   self,
            name        = "AppLane",
            description = "PCIe Application Lane Container",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        #######################################
        # SLAVE[INDEX=0][TDEST=0] = XPM Trigger
        # SLAVE[INDEX=0][TDEST=1] = XPM Event Transition
        # SLAVE[INDEX=1][TDEST=2] = Camera Image
        # SLAVE[INDEX=2][TDEST=3] = XPM Timing
        #######################################
        self.add(batcher.AxiStreamBatcherEventBuilder(
            name         = 'EventBuilder',
            offset       = 0x0_0000,
            numberSlaves = 3, # Total number of slave indexes (not necessarily same as TDEST)
            tickUnit     = '156.25MHz',
            expand       = True,
        ))

        # weaver - cameralink-gateway firmware now uses 
        #   lcls2-pgp-fw-lib/Application.vhd, but the python support
        #   for this is not in the lcls2-pgp-fw-lib tag.  Add it here:
        #   Tap register at address 0 and shift XpmPauseThreshold to address 4
        self.add(pr.RemoteVariable(
            name         = 'VcTap',
            description  = 'Virtual channel for event builder output',
            offset       = 0x1_0100,
            bitSize      = 3,
            mode         = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name         = 'XpmPauseThresh',
            description  = 'Threshold in unit of AXIS words (8 bytes per word).  The XPM is 48byte message. So setting this register to 0x7 would NOT back pressure until there is two message in the pipeline',
            offset       = 0x1_0104,
            bitSize      = 9,
            mode         = 'RW',
        ))

class Application(pr.Device):
    def __init__(   self,
            name        = "Application",
            description = "PCIe Lane Container",
            laneConfig  = {0: 'Opal1000'},
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        for i in laneConfig:
            self.add(AppLane(
                name   = f'AppLane[{i}]',
                offset = (i*0x0008_0000),
                expand = True,
            ))
