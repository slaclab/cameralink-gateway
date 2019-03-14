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

    timeout = 0.1

    # Set the baud rate to 57600
    ch[args.serCh].BaudRate.set(57600)

    # Output resolution, i.e. bits per pixel.  Set to 12. (value from Bruce Hill)
    ch[args.serCh].SendString('@OR12\r')  
    time.sleep(timeout)    
    ch[args.serCh].SendString('@OR?\r') 
    time.sleep(timeout)           
       
    # Pulse width exposure control (value from Bruce Hill)
    ch[args.serCh].SendString('@MO1\r')
    time.sleep(timeout)    
    ch[args.serCh].SendString('@MO?\r') 
    time.sleep(timeout)    
       
    # Vertical binning, set to 1. (value from Bruce Hill)
    ch[args.serCh].SendString('@VBIN1\r')    
    time.sleep(timeout)    
    ch[args.serCh].SendString('@VBIN?\r') 
    time.sleep(timeout)           
       
    # Enable vertical remapping (deinterlace on camera w/ 4ms delay, value from Bruce Hill)
    ch[args.serCh].SendString('@VR1\r')
    time.sleep(timeout)    
    ch[args.serCh].SendString('@VR?\r') 
    time.sleep(timeout)         
       
    # Normal Polarity CC1 trigger  (value from Bruce Hill)
    ch[args.serCh].SendString('@CCE0;0\r')
    time.sleep(timeout)    
    ch[args.serCh].SendString('@CCE?\r')
    time.sleep(timeout)    
    
    # Set CCFS to default value of [0,0]
    ch[args.serCh].SendString('@CCFS0;0\r')
    time.sleep(timeout)    
    ch[args.serCh].SendString('@CCFS?\r')
    time.sleep(timeout)    
    
    # Set DPE to default value of 1
    ch[args.serCh].SendString('@DPE1\r')  
    time.sleep(timeout)    
    ch[args.serCh].SendString('@DPE?\r') 
    time.sleep(timeout)    
 
    # Set FSM to default value of 0
    ch[args.serCh].SendString('@FSM0\r')    
    time.sleep(timeout)    
    ch[args.serCh].SendString('@FSM?\r') 
    time.sleep(timeout)    
    
    # Set FST to default value of [0,1]
    ch[args.serCh].SendString('@FST0;1\r')   
    time.sleep(timeout)    
    ch[args.serCh].SendString('@FST?\r') 
    time.sleep(timeout)    

    # Set GA to default value of 100
    ch[args.serCh].SendString('@GA100\r')       
    time.sleep(timeout)    
    ch[args.serCh].SendString('@GA?\r') 
    time.sleep(timeout)    

    # Set MI to default value of 0
    ch[args.serCh].SendString('@MI0\r')      
    time.sleep(timeout)    
    ch[args.serCh].SendString('@MI?\r') 
    time.sleep(timeout)    
        
    # Set TP to default value of 0
    ch[args.serCh].SendString('@TP0\r')      
    time.sleep(timeout)    
    ch[args.serCh].SendString('@TP?\r') 
    time.sleep(timeout)    
      
    # Set BL to default value of 20
    ch[args.serCh].SendString('@BL20\r')     
    time.sleep(timeout)    
    ch[args.serCh].SendString('@BL?\r') 
    time.sleep(timeout)    
    
else:
    # PGP Link down
    raise ValueError(f'Pgp[lane={args.pgpLane}] is down')
    
time.sleep(timeout)    
time.sleep(timeout)    
time.sleep(timeout)    

cl.stop()
exit()
