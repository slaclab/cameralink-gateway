#-----------------------------------------------------------------------------
# This file is part of the 'Camera link gateway'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Camera link gateway', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import setupLibPaths

import os
import time
import sys
import argparse
import rogue
import pyrogue as pr
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

parser.add_argument(
    "--dev",
    type     = str,
    required = False,
    default  = '/dev/datadev_0',
    help     = "path to device",
)

parser.add_argument(
    "--lane",
    type     = int,
    required = True,
    help     = "lane index",
)

parser.add_argument(
    "--xDim",
    type     = int,
    required = True,
    help     = "Camera Image: number of pixels wide",
)

parser.add_argument(
    "--yDim",
    type     = int,
    required = True,
    help     = "Camera Image: number of pixels high",
)

parser.add_argument(
    "--bytePerPix",
    type     = int,
    required = True,
    help     = "Number of bytes per pixel",
)

parser.add_argument(
    "--deca",
    type     = argBool,
    required = False,
    default  = False,
    help     = "Enable DECA mode",
)

# Get the arguments
args = parser.parse_args()

#################################################################

class EventReader(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)
        if args.deca:
            self.dtype = 'uint8'
            self.imageSize = (10*args.xDim*args.yDim)//8

        else:
            self.dtype     = 'int16' if (args.bytePerPix==2) else 'uint8'
            self.imageSize = (args.xDim*args.yDim)

        self.image     = [[0 for x in range(args.xDim)] for y in range(args.yDim)]
        self.nextPlot  = False

    def _acceptFrame(self, frame):
        channel = frame.getChannel()
        # Check for camera image destination
        if (channel == 2) and not self.nextPlot:
            frameSize = frame.getPayload()
            ba = bytearray(frameSize)
            frame.read(ba, 0)
            data = np.frombuffer(ba, dtype=self.dtype, count=self.imageSize)
            if args.deca:
                x=0
                y=0
                for i in range(self.imageSize//5):
                    word = np.int64(0)
                    for j in range(5):
                        word = word<<8 | np.int64(0xFF&data[ 5*i + 4-j ])
                    for j in range(4):
                        self.image[y][x] = (word>>(10*j))&0x3FF
                        x += 1
                        if x==args.xDim:
                            x=0
                            y += 1

            else:
                for y in range(args.yDim):
                    for x in range(args.xDim):
                        self.image[y][x] = data[y*args.xDim+x]
            self.nextPlot  = True

#################################################################

class myRoot(pr.Root):
    def __init__(self,**kwargs):
        super().__init__(**kwargs)

        self.dmaStream   = rogue.hardware.axi.AxiStreamDma(args.dev,(0x100*args.lane)+1,1)
        self.fifo = pr.interfaces.stream.Fifo(
            name        = 'LiveDisplayDropFifo',
            description = 'Fifo to prevent back pressuring stream',
            maxDepth    = 1, # Drop if more than 1 frame in FIFO
            trimSize    = 0, # No triming
            noCopy      = False, # Create copy of buffer
        )
        self.unbatcher   = rogue.protocols.batcher.SplitterV1()
        self.eventReader = EventReader()

        self.dmaStream >> self.fifo >> self.unbatcher >> self.eventReader

    def updatePlot(self,i):
        if self.eventReader.nextPlot:
            plt.imshow(self.eventReader.image, cmap='gray')
            self.eventReader.nextPlot = False

#################################################################

with myRoot() as root:

    ani = animation.FuncAnimation(plt.gcf(), root.updatePlot, interval=200)
    plt.show()

    while(1):
        time.sleep(0.001)

#################################################################
