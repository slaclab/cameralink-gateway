# Define Firmware Version: v4.0.0.0
export PRJ_VERSION = 0x04000000

# Prom type: s25fl128sxxxxxx0-spi-x1_x2_x4
target: prom

# Define target part
export PRJ_PART = XC7K70Tfbg484-2

# Define release
ifndef RELEASE
export RELEASE = all
endif
