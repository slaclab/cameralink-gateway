#!/usr/bin/env python3
import pyrogue as pr
import rogue.hardware.data
import rogue.protocols
import surf.axi
import surf.protocols.clink

class ClinkDev(pr.Root):

    def __init__(self):

        pr.Root.__init__(self,name='ClinkDev',description='CameraLink Dev')

        # Create the stream interface
        pgpVc0 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,0) # Registers
        pgpVc1 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,1) # Data
        pgpVc2 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,2) # Serial

        # SRP
        srp = rogue.protocols.srp.SrpV3()
        pr.streamConnectBiDir(pgpVc0,srp)

        # Version registers
        self.add(surf.axi.AxiVersion(memBase=srp,offset=0))
        self.add(surf.protocols.clink.ClinkTop(memBase=srp,offset=0x10000,serial=pgpVc2))

        # Start the system
        self.start(pollEn=False)


