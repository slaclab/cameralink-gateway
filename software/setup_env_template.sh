# Setup environment
source /afs/slac.stanford.edu/g/reseng/rogue/anaconda/rogue_pre-release.sh

# Package directories
export LOC_DIR=${PWD}/python
export PCIE_DIR=${PWD}/../firmware/submodules/axi-pcie-core/python
export PGP_DIR=${PWD}/../firmware/submodules/lcls2-pgp-fw-lib/python
export TIME_DIR=${PWD}/../firmware/submodules/lcls-timing-core/python
export FEB_DIR=${PWD}/../firmware/submodules/clink-gateway-fw-lib/python
export SURF_DIR=${PWD}/../firmware/submodules/surf/python

# Setup python path
export PYTHONPATH=${LOC_DIR}:${PCIE_DIR}:${PGP_DIR}:${TIME_DIR}:${FEB_DIR}:${SURF_DIR}:${PYTHONPATH}
