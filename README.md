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

# How to build the FEB firmware

1) Setup Xilinx licensing
```
$ source cameralink-gateway/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd cameralink-gateway/firmware/targets/ClinkFebPgp2b_1ch/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

<!--- ######################################################## -->

# How to build the PCIe firmware

1) Setup Xilinx licensing
```
$ source cameralink-gateway/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd cameralink-gateway/firmware/targets/ClinkKcu1500Pgp2b/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

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
where <PATH_TO_IMAGE_DIR> is path to image directory (example: ../firmware/targets/ClinkKcu1500Pgp2b/images/)

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
$ python scripts/gui.py --camTypeA TYPE_A
where <TYPE_A> is the camera type on ch[0] of the FEB (example: --camTypeA Opal1000)
```

# Example of starting up OPAL1000
```
$ python scripts/gui.py --camTypeA Opal1000 --defaultFile config/Opal1000.yml
Then execute the StartRun() command to start the triggering
```

<!--- ######################################################## -->
