
# Rogue
source /afs/slac.stanford.edu/g/reseng/rogue/master/setup_env.csh

# Package directories
setenv SURF_DIR ${PWD}/../firmware/submodules/surf/python/
setenv NNET_DIR ${PWD}/../firmware/submodules/neuralnet-fw-lib/python/

setenv LOC_DIR ${PWD}/python/

# Setup python path
setenv PYTHONPATH ${SURF_DIR}:${LOC_DIR}:${PYTHONPATH}

