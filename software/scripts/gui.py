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
import pyrogue.gui
import ClinkDev
import sys
import argparse

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

# Add arguments
parser.add_argument(
    "--dev", 
    type     = str,
    required = False,
    default  = '/dev/datadev_0',
    help     = "path to device",
)  

parser.add_argument(
    "--version3", 
    type     = argBool,
    required = False,
    default  = False,
    help     = "true = PGPv3, false = PGP2b",
) 

parser.add_argument(
    "--pollEn", 
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable auto-polling",
) 

parser.add_argument(
    "--initRead", 
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable read all variables at start",
)  

parser.add_argument(
    "--numLane", 
    type     = int,
    required = False,
    default  = 4,
    help     = "PGP lane index (range from 1 to 4)",
)  

# Get the arguments
args = parser.parse_args()

#################################################################

cl = ClinkDev.ClinkDev(
    dev      = args.dev,
    version3 = args.version3,
    pollEn   = args.pollEn,
    initRead = args.initRead,
    numLane  = args.numLane,
)

#################################################################

# # Dump the address map
# pr.generateAddressMap(cl,'addressMapDummp.txt')

# Create GUI
appTop = pyrogue.gui.application(sys.argv)
guiTop = pyrogue.gui.GuiTop(group='ClinkDev')
guiTop.addTree(cl)
guiTop.resize(800, 1200)

# Run gui
appTop.exec_()
cl.stop()

