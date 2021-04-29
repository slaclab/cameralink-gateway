from setuptools import setup

# use softlinks to make the various "board-support-package" submodules
# look like subpackages.  Then __init__.py will modify
# sys.path so that the correct "local" versions of surf etc. are
# picked up.  A better approach would be using relative imports
# in the submodules, but that's more work.  -cpo
setup(
    name = 'cameralink_gateway',
    description = 'LCLS II cameralink package',
    packages = [
        'cameralink_gateway',
        'cameralink_gateway.surf',
        'cameralink_gateway.surf.misc',
        'cameralink_gateway.surf.ethernet.mac',
        'cameralink_gateway.surf.ethernet.xaui',
        'cameralink_gateway.surf.ethernet.gige',
        'cameralink_gateway.surf.ethernet.ten_gig',
        'cameralink_gateway.surf.ethernet',
        'cameralink_gateway.surf.ethernet.udp',
        'cameralink_gateway.surf.protocols',
        'cameralink_gateway.surf.protocols.pgp',
        'cameralink_gateway.surf.protocols.ssp',
        'cameralink_gateway.surf.protocols.rssi',
        'cameralink_gateway.surf.protocols.jesd204b',
        'cameralink_gateway.surf.protocols.ssi',
        'cameralink_gateway.surf.protocols.i2c',
        'cameralink_gateway.surf.protocols.batcher',
        'cameralink_gateway.surf.protocols.clink',
        'cameralink_gateway.surf.xilinx',
        'cameralink_gateway.surf.devices.microchip',
        'cameralink_gateway.surf.devices.ti',
        'cameralink_gateway.surf.devices',
        'cameralink_gateway.surf.devices.transceivers',
        'cameralink_gateway.surf.devices.analog_devices',
        'cameralink_gateway.surf.devices.micron',
        'cameralink_gateway.surf.devices.linear',
        'cameralink_gateway.surf.devices.nxp',
        'cameralink_gateway.surf.devices.cypress',
        'cameralink_gateway.surf.devices.silabs',
        'cameralink_gateway.surf.devices.intel',
        'cameralink_gateway.surf.axi',
        'cameralink_gateway.l2si_core',
        'cameralink_gateway.LclsTimingCore',
        'cameralink_gateway.axipcie',
        'cameralink_gateway.lcls2_pgp_fw_lib',
        'cameralink_gateway.lcls2_pgp_fw_lib.shared',
        'cameralink_gateway.ClinkFeb', 
    ],
    package_dir = {
        'cameralink_gateway': 'firmware/python/cameralink_gateway',
        'cameralink_gateway.surf': 'firmware/submodules/surf/python/surf',
        'cameralink_gateway.axipcie': 'firmware/submodules/axi-pcie-core/python/axipcie',
        'cameralink_gateway.LclsTimingCore': 'firmware/submodules/lcls-timing-core/python/LclsTimingCore',
        'cameralink_gateway.lcls2_pgp_fw_lib': 'firmware/submodules/lcls2-pgp-fw-lib/python/lcls2_pgp_fw_lib',
        'cameralink_gateway.ClinkFeb': 'firmware/submodules/clink-gateway-fw-lib/python/ClinkFeb',
        'cameralink_gateway.l2si_core': 'firmware/submodules/l2si-core/python/l2si_core',
    }
)

