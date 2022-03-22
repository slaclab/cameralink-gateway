# cameralink-gateway

<!--- ######################################################## -->

# Before you clone the GIT repository

1) Create a github account:
> https://github.com/

2) On the Linux machine that you will clone the github from, generate a SSH key (if not already done)
> https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

3) Add a new SSH key to your GitHub account
> https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

4) Setup for large filesystems on github

```
$ git lfs install
```

5) Verify that you have git version 2.13.0 (or later) installed 

```
$ git version
git version 2.13.0
```

6) Verify that you have git-lfs version 2.1.1 (or later) installed 

```
$ git-lfs version
git-lfs/2.1.1
```

# Clone the GIT repository

```
$ git clone --recursive git@github.com:slaclab/cameralink-gateway
```

<!--- ######################################################## -->

# FEB's dual stack LED Definition

```
LED[TOP].Green = PGP2b Link Up
LED[TOP].Blue  = PGPv4 Link Up
LED[TOP].Red   = Unused (always OFF)

LED[BOTTOM].Green = CLINK Running
LED[BOTTOM].Blue  = Unused (always OFF)
LED[BOTTOM].Red   = CLINK not Running
```

<!--- ######################################################## -->

# FEB's SFP Fiber mapping

```
SFP[0] = PGP2b
SFP[1] = PGPv4
SFP[2] = Unused
SFP[3] = Unused
```

SFP[0] is fiber closed to the power connector.  Numbering goes from left to right with SFP[3] closest to JTAG connector.

<!--- ######################################################## -->

# SLAC PGP GEN4 PCIe Fiber mapping

```
QSFP[0][0] = PGP.Lane[0].VC[3:0]
QSFP[0][1] = PGP.Lane[1].VC[3:0]
QSFP[0][2] = PGP.Lane[2].VC[3:0]
QSFP[0][3] = PGP.Lane[3].VC[3:0]
QSFP[1][0] = LCLS-I  Timing Receiver
QSFP[1][1] = LCLS-II Timing Receiver
QSFP[1][2] = Unused QSFP Link
QSFP[1][3] = Unused QSFP Link
SFP = Unused SFP Link
```

<!--- ######################################################## -->

# C1100 (or KCU1500) PCIe Fiber mapping

```
QSFP[0][0] = PGP.Lane[0].VC[3:0]
QSFP[0][1] = PGP.Lane[1].VC[3:0]
QSFP[0][2] = PGP.Lane[2].VC[3:0]
QSFP[0][3] = PGP.Lane[3].VC[3:0]
QSFP[1][0] = LCLS-I  Timing Receiver
QSFP[1][1] = LCLS-II Timing Receiver
QSFP[1][2] = Unused QSFP Link
QSFP[1][3] = Unused QSFP Link
```

<!--- ######################################################## -->

# PGP Virtual Channel Mapping

```
PGP[lane].VC[0] = SRPv3 (register access)
PGP[lane].VC[1] = Camera Image (streaming data)
PGP[lane].VC[2] = Camera UART (streaming data)
PGP[lane].VC[3] = SEM UART (streaming data)
```

<!--- ######################################################## -->

# DMA channel mapping

```
DMA[lane].DEST[0] = SRPv3
DMA[lane].DEST[1] = Event Builder Batcher (super-frame)
DMA[lane].DEST[1].DEST[0] = XPM Trigger Message (sub-frame)
DMA[lane].DEST[1].DEST[1] = XPM Transition Message (sub-frame)
DMA[lane].DEST[1].DEST[2] = Camera Image (sub-frame)
DMA[lane].DEST[1].DEST[3] = XPM Timing Message (sub-frame)
DMA[lane].DEST[2] = Camera UART
DMA[lane].DEST[3] = SEM UART
DMA[lane].DEST[255:4] = Unused
```


<!--- ######################################################## -->

# How to build the FEB firmware

1) Setup Xilinx licensing
```
$ source cameralink-gateway/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd cameralink-gateway/firmware/targets/ClinkFeb/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

<!--- ######################################################## -->

# How to build the PCIe firmware

PCIe firmware images are attached to the tag releases of "slaclab/lcls2-pgp-pcie-apps" and no longer built in this github repo

https://github.com/slaclab/lcls2-pgp-pcie-apps

<!--- ######################################################## -->

# How to load the driver

```
# Confirm that you have the board the computer with VID=1a4a ("SLAC") and PID=2030 ("AXI Stream DAQ")
$ lspci -nn | grep SLAC
04:00.0 Signal processing controller [1180]: SLAC National Accelerator Lab TID-AIR AXI Stream DAQ PCIe card [1a4a:2030]

# Clone the driver github repo:
$ git clone --recursive https://github.com/slaclab/aes-stream-drivers

# Go to the driver directory
$ cd aes-stream-drivers/data_dev/driver/

# Build the driver
$ make

# Load the driver
$ sudo /sbin/insmod ./datadev.ko cfgSize=0x50000 cfgRxCount=256 cfgTxCount=16

# Give appropriate group/permissions
$ sudo chmod 666 /dev/datadev*

# Check for the loaded device
$ cat /proc/datadev0

```

<!--- ######################################################## -->

# How to install the Rogue With Anaconda

> https://slaclab.github.io/rogue/installing/anaconda.html

<!--- ######################################################## -->

# XPM Triggering Documentation

https://docs.google.com/document/d/1B_sIkk9Fxsw2EjOBpGVFpfCCWoIiOJoVGTrkTshZfew/edit?usp=sharing

<!--- ######################################################## -->

# How to reprogram the FEB firmware via Rogue software

1) Setup the rogue environment
```
$ cd cameralink-gateway/software
$ source setup_env_template.sh
```

2) Run the FEB firmware update script:
```
$ python scripts/updateFebFpga.py --lane <PGP_LANE> --mcs <PATH_TO_MCS>
```
where <PGP_LANE> is the PGP lane index (range from 0 to 3)
and <PATH_TO_MCS> is the path to the firmware .MCS file


<!--- ######################################################## -->

# How to reprogram the PCIe firmware via Rogue software

1) Setup the rogue environment
```
$ cd cameralink-gateway/software
$ source setup_env_slac.sh
```

2) Run the PCIe firmware update script:
```
$ python scripts/updatePcieFpga.py --path <PATH_TO_IMAGE_DIR>
```
where <PATH_TO_IMAGE_DIR> is path to image directory (example: ../../lcls2-pgp-pcie-apps/firmware/targets/XilinxC1100/Lcls2XilinxC1100Pgp4_6Gbps/images/)

3) Reboot the computer
```
sudo reboot
```

<!--- ######################################################## -->

# How to run the Rogue PyQT GUI

1) Setup the rogue environment
```
$ cd cameralink-gateway/software
$ source setup_env_slac.sh
```

2) Lauch the GUI:
```
$ python scripts/devGui --pgp4 IS_PGP4_BOOL --laneConfig LANE_CONFIG_DICTIONARY
```

# Example of starting up OPAL1000 on Lane[0] with PGP4 (instead of PGP2b) and stand alone mode (locally generated timing)
```
$ python scripts/devGui --pgp4 1 --laneConfig 0=Opal1000 --standAloneMode 1
Then execute the StartRun() command to start the triggering
```

<!--- ######################################################## -->
