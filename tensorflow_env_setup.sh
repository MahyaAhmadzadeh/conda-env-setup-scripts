#!/bin/bash

# Create TensorFlow environment
conda create -n tensorflow_env python=3.11.9
conda activate tensorflow_env

# Install TensorFlow with CUDA support
pip install tensorflow[and-cuda]~=2.16.1

# Install additional requirements from a requirements file
pip install -r requirements-common.txt

# Set up activation and deactivation scripts
cd $CONDA_PREFIX
mkdir -p ./etc/conda/activate.d
mkdir -p ./etc/conda/deactivate.d
touch ./etc/conda/activate.d/env_vars.sh
touch ./etc/conda/deactivate.d/env_vars.sh

# Edit activate script
echo '#!/bin/sh
NVIDIA_DIR=$(dirname $(python -c "import nvidia;print(nvidia.__file__)"))
export PREV_LDLIBPATH=$(echo ${LD_LIBRARY_PATH})
export LD_LIBRARY_PATH=$(echo ${NVIDIA_DIR}/*/lib/ | sed -r "s/\s+/:/g")${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export KERAS_BACKEND="tensorflow"' > ./etc/conda/activate.d/env_vars.sh

# Edit deactivate script
echo '#!/bin/sh
export LD_LIBRARY_PATH=$(echo ${PREV_LDLIBPATH})' > ./etc/conda/deactivate.d/env_vars.sh

# Verify installation
conda deactivate
conda activate tensorflow_env
echo $LD_LIBRARY_PATH
python -c "import tensorflow as tf; print(tf.config.list_physical_devices());"
