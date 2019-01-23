# Rogue
source /afs/slac.stanford.edu/g/reseng/rogue/pre-release/setup_env.csh

# Package directories
setenv LOC_DIR  ${PWD}/python/
setenv SURF_DIR ${PWD}/../firmware/submodules/surf/python/

# Setup python path
setenv PYTHONPATH ${SURF_DIR}:${LOC_DIR}:${PYTHONPATH}
