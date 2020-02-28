# Define Firmware Version: v4.0.0.2
export PRJ_VERSION = 0x04000002

# Prom type: mt25qu512-spi-x1_x2_x4_x8
target: prom

# Define release
ifndef RELEASE
export RELEASE = all
endif
