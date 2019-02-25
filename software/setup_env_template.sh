# Setup environment
source /afs/slac.stanford.edu/g/reseng/rogue/anaconda/rogue_pre-release.sh

# Package directories
export  LOC_DIR=${PWD}/python
export SURF_DIR=${PWD}/../firmware/submodules/surf/python
export PCIE_DIR=${PWD}/../firmware/submodules/axi-pcie-core/python

# Setup python path
export PYTHONPATH=${LOC_DIR}:${PCIE_DIR}:${SURF_DIR}:${PYTHONPATH}
