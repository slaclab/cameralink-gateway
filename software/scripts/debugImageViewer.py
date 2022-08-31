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


# Get the arguments
args = parser.parse_args()

#################################################################

class EventReader(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)
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
            for y in range(args.yDim):
                for x in range(args.xDim):
                    self.image[y][x] = data[y*args.xDim+x]
            self.nextPlot  = True

#################################################################

class myRoot(pr.Root):
    def __init__(self,**kwargs):
        super().__init__(**kwargs)

        self.dmaStream   = rogue.hardware.axi.AxiStreamDma(args.dev,(0x100*args.lane)+1,1)
        self.rateDrop    = rogue.interfaces.stream.RateDrop(True,1.0)
        self.fifo        = rogue.interfaces.stream.Fifo(10,0,False)
        self.unbatcher   = rogue.protocols.batcher.SplitterV1()
        self.eventReader = EventReader()

        self.dmaStream >> self.rateDrop >> self.fifo >> self.unbatcher >> self.eventReader

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
