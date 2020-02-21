# Define Firmware Version: v3.0.5.0
export PRJ_VERSION = 0x03050000

# Prom type: mt25qu512-spi-x1_x2_x4_x8
target: prom

# Define release
ifndef RELEASE
export RELEASE = all
endif
