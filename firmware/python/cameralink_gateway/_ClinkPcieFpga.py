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
import pyrogue as pr

import axipcie                 as pcie
import lcls2_pgp_fw_lib.shared as shared
import surf.axi                as axi

# _EXTREF firmware Si570 timing reference (MHz), indexed by TimingFrameRx.ClkSel
EXTREF_FREQ_C = [
    119.0,         # 0: LCLS-I
    1300.0/7.0,    # 1: LCLS-II (185.714 MHz)
]

class ClinkPcieFpga(pr.Device):
    def __init__(self,
                 laneConfig = {0: 'Opal1000'},
                 pgp4       = False,
                 enLclsI    = True,
                 enLclsII   = False,
                 boardType  = None,
                 useDdr     = False,
                 **kwargs):
        super().__init__(**kwargs)

        # Core Layer
        self.add(pcie.AxiPcieCore(
            offset      = 0x0000_0000,
            numDmaLanes = 4,
            boardType   = boardType,
            expand      = False,
        ))

        if useDdr:
            for i in range(4):
                self.add(axi.AxiStreamDmaV2Fifo(
                    name    = f'DmaBuffer[{i}]',
                    offset  = 0x0010_0000+i*0x100,
                    expand  = False,
                ))

        # Application layer
        self.add(shared.ApplicationLaneConfigDict(
            offset     = 0x00C0_0000,
            laneConfig = laneConfig,
            expand     = True,
        ))

        # Hardware Layer
        self.add(shared.Hsio(
            name       = 'Hsio',
            offset     = 0x0080_0000,
            laneConfig = laneConfig,
            pgp4       = pgp4,
            enLclsI    = enLclsI,
            enLclsII   = enLclsII,
            expand     = True,
        ))

        # Every timing mode change (ConfigLclsTimingV1/V2, ConfigureXpmMini,
        # ConfigureTpgMiniStream) goes through ConfigLclsTimingBase, which resets
        # the timing clocks and PHYs. Retune the Si570 first on _EXTREF firmware.
        timingRx   = self.Hsio.TimingRx
        configBase = timingRx.ConfigLclsTimingBase

        def configLclsTimingBase(ClkSel, UseMiniTpg):
            self.SetExtRefClk(ClkSel)
            configBase(ClkSel=ClkSel, UseMiniTpg=UseMiniTpg)

        timingRx.ConfigLclsTimingBase = configLclsTimingBase

    def SetExtRefClk(self, clkSel):
        # Legacy firmware uses the fixed GT reference clocks: nothing to program
        if not self.AxiPcieCore.AxiVersion.ImageName.get().endswith('_EXTREF'):
            return

        if not hasattr(self.AxiPcieCore, 'Si570'):
            raise ValueError(f'{self.path}: _EXTREF firmware requires pcieBoardType=XilinxKcu1500 to program the Si570 timing reference')

        si570 = self.AxiPcieCore.Si570
        freq  = EXTREF_FREQ_C[clkSel]
        print(f'{self.path}.SetExtRefClk(): Si570.Frequency = {freq:.6f} MHz')

        # Si570 is disabled by default (slow I2C), so only enable it while programming
        enable = si570.enable.get()
        si570.enable.set(True)
        try:
            si570.Frequency.set(freq)
        finally:
            if enable is False:
                si570.enable.set(False)
