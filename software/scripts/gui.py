#!/usr/bin/env python3
import pyrogue.gui
import ClinkDev
import sys

cl = ClinkDev.ClinkDev()

# Create GUI
appTop = pyrogue.gui.application(sys.argv)
guiTop = pyrogue.gui.GuiTop(group='ClinkDev')
guiTop.addTree(cl)

# Run gui
appTop.exec_()
cl.stop()

