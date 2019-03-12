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

import ClinkDev
import sys
import argparse
import time

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
    "--serCh", 
    type     = int,
    required = False,
    default  = 0,
    help     = "serial channel",
) 

parser.add_argument(
    "--lane", 
    type     = int,
    required = True,
    help     = "PGP lane index (range from 0 to 3)",
)  

# Get the arguments
args = parser.parse_args()

#################################################################

cl = ClinkDev.ClinkDev(
    dev      = args.dev,
    version3 = args.version3,
    pollEn   = False,
    initRead = False,
)
    
# Create useful pointers
ch =  [None for lane in range(2)]
ch[0] = cl.ClinkFeb[args.lane].ClinkTop.ChannelA
ch[1] = cl.ClinkFeb[args.lane].ClinkTop.ChannelB

if (cl.Hardware.PgpMon[args.lane].RxRemLinkReady.get()):
    # Set the baud rate to 57600
    ch[args.serCh].BaudRate.set(57600)
    time.sleep(0.1)    
    
    # Serial commands for setup w/ normal polarity CC1 trigger  (value from Bruce Hill)
    ch[args.serCh].SendString('@CCE0;0\r')
    time.sleep(0.1)    
    
    # Set CCFS to default value of [0,0]
    ch[args.serCh].SendString('@CCFS0;0\r')
    time.sleep(0.1)    
    
    # Set DPE to default value of 1
    ch[args.serCh].SendString('@DPE1\r')  
    time.sleep(0.1)    

    # Set FP to default value of 815
    ch[args.serCh].SendString('@FP815\r')
    time.sleep(0.1)    

    # Set FSM to default value of 0
    ch[args.serCh].SendString('@FSM0\r')    
    time.sleep(0.1)    
    
    # Set FST to default value of [0,1]
    ch[args.serCh].SendString('@FST0;1\r')   
    time.sleep(0.1)    

    # Set GA to default value of 100
    ch[args.serCh].SendString('@GA100\r')       
    time.sleep(0.1)    
    
    # Set IT to default value of 814
    ch[args.serCh].SendString('@IT814\r')  
    time.sleep(0.1)    

    # Set MI to default value of 0
    ch[args.serCh].SendString('@MI0\r')      
    time.sleep(0.1)    
    
    # Pulse width exposure control (value from Bruce Hill)
    ch[args.serCh].SendString('@MO1\r')
    time.sleep(0.1)    
    
    # Set OFS to default value of 20
    ch[args.serCh].SendString('@OFS20\r')  
    time.sleep(0.1)    

    # Output resolution, i.e. bits per pixel.  Set to 12. (value from Bruce Hill)
    ch[args.serCh].SendString('@OR12\r')  
    time.sleep(0.1)    
    
    # Set TP to default value of 0
    ch[args.serCh].SendString('@TP0\r')      
    time.sleep(0.1)    
    
    # Vertical binning, set to 1. (value from Bruce Hill)
    ch[args.serCh].SendString('@VBIN1\r')    
    time.sleep(0.1)    
    
    # Set WB to default value of [100,100,100]
    ch[args.serCh].SendString('@WB100;100;100\r')    
    time.sleep(0.1)    
    
    # Set BL to default value of 20
    ch[args.serCh].SendString('@BL20\r')     
    time.sleep(0.1)    
    
    # Enable vertical remapping (deinterlace on camera w/ 4ms delay, value from Bruce Hill)
    ch[args.serCh].SendString('@VR1\r')
    time.sleep(0.1)    
    
    # Set FSP to default value of 0
    ch[args.serCh].SendString('@FSP0\r')     
    time.sleep(0.1)    
    
else:
    # PGP Link down
    raise ValueError(f'Pgp[lane={args.pgpLane}] is down')

time.sleep(0.1)    
    
cl.stop()
exit()
