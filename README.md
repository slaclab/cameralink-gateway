# cameralink-gateway

<!--- ######################################################## -->

# Clone the GIT repository

Install git large filesystems (git-lfs) in your .gitconfig (1-time step per unix environment)
```bash
$ git lfs install
```
Clone the git repo with git-lfs enabled
```bash
$ git clone --recursive https://github.com/slaclab/cameralink-gateway.git
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

# FPGA PCIe card Github repo (cameralink-gateway@v8.0.0 or later)

https://github.com/slaclab/lcls2-pgp-pcie-apps

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

# How to load the driver

https://confluence.slac.stanford.edu/x/HLuDFg

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

https://github.com/slaclab/lcls2-pgp-pcie-apps/blob/master/README.md#how-to-reprogram-the-pcie-firmware-via-rogue-software

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
