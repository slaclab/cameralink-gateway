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
    "--hwType", 
    type     = str,
    required = False,
    default  = 'kcu1500',
    help     = "kcu1500 or SlacPgpCardG4",
)  

parser.add_argument(
    "--camType", 
    nargs    ='+',
    required = True,
    help     = "List of camera type",
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

# Select the hardware type
if args.hwType == 'kcu1500':
    args.clDevTarget = ClinkDev.ClinkDevKcu1500
else:
    args.clDevTarget = ClinkDev.ClinkDevSlacPgpCardG4

#################################################################

with ClinkDev.ClinkDevRoot(**vars(args)) as root:

    pyrogue.pydm.runPyDM(root=root)
    
#################################################################
