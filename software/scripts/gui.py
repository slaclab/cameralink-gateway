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

import sys
import argparse

import setupLibPaths
import pyrogue.gui
import pyrogue.pydm
import ClinkDev

import rogue

#################################################################

#rogue.Logging.setFilter('pyrogue.batcher', rogue.Logging.Debug)

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
    "--numLanes", 
    type     = int,
    required = False,
    default  = 4,
    help     = "PGP lane index (range from 1 to 4)",
)  

parser.add_argument(
    "--camTypeA", 
    type     = str,
    required = True,
    help     = "Sets the camera type on Feb.ClinkTop.ch[0] Interfaces",
) 

parser.add_argument(
    "--camTypeB", 
    type     = str,
    required = False,
    default  = None,
    help     = "Sets the camera type on Feb.ClinkTop.ch[1] Interfaces",
) 


parser.add_argument(
    "--defaultFile", 
    type     = str,
    required = False,
    default  = None,
    help     = "Sets the default YAML configuration file to be loaded at the root.start()",
) 

parser.add_argument(
    "--serverPort", 
    type     = int,
    required = False,
    default  = 9099,
    help     = "Zeromq server port",
)
# Get the arguments
args = parser.parse_args()

#################################################################

with ClinkDev.ClinkDevKcu1500Root(**vars(args)) as root:

    pyrogue.pydm.runPyDM(root=root)
    
#################################################################
