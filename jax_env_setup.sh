#!/bin/bash

# Create JAX environment
conda create -n jax_env python=3.11.9
conda init
conda activate jax_env


# Install TensorFlow CPU-only version
pip install tensorflow-cpu~=2.16

# Install JAX and keras
pip install --find-links https://storage.googleapis.com/jax-releases/jax_cuda_releases.html jax[cuda12_pip]==0.4.23 flax

# Install additional requirements from requirements-common.txt
pip install -r requirements-common.txt

# Set up activation and deactivation scripts
cd $CONDA_PREFIX
mkdir -p ./etc/conda/activate.d
mkdir -p ./etc/conda/deactivate.d
touch ./etc/conda/activate.d/env_vars.sh
touch ./etc/conda/deactivate.d/env_vars.sh

# Edit activate script (you alternatively can use any editor to paste the below in the scripts)
echo '#!/bin/sh
NVIDIA_DIR=$(dirname $(python -c "import nvidia;print(nvidia.__file__)"))
export PREV_LDLIBPATH=$(echo ${LD_LIBRARY_PATH})
export LD_LIBRARY_PATH=$(echo ${NVIDIA_DIR}/*/lib/ | sed -r "s/\s+/:/g")${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export KERAS_BACKEND="jax"' > ./etc/conda/activate.d/env_vars.sh

# Edit deactivate script
echo '#!/bin/sh
export LD_LIBRARY_PATH=$(echo ${PREV_LDLIBPATH})' > ./etc/conda/deactivate.d/env_vars.sh

# Verify installation
conda deactivate
conda activate jax_env
echo $LD_LIBRARY_PATH
python -c "import jax; print(jax.devices());"
