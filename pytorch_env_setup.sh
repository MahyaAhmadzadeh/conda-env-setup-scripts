#!/bin/bash

# Create PyTorch environment
conda create -n pytorch_env python=3.11.9
conda activate pytorch_env


# TensorFlow CPU-only version
pip install tensorflow-cpu~=2.16.1


# Install PyTorch and Keras
pip install --extra-index-url https://download.pytorch.org/whl/cu121 torch==2.2.1+cu121 torchvision==0.17.1+cu121


# Install additional requirements from a file:
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
export KERAS_BACKEND="torch"' > ./etc/conda/activate.d/env_vars.sh

# Edit deactivate script
echo '#!/bin/sh
export LD_LIBRARY_PATH=$(echo ${PREV_LDLIBPATH})' > ./etc/conda/deactivate.d/env_vars.sh

# Verify installation
conda deactivate
conda activate pytorch_env
echo $LD_LIBRARY_PATH
python -c "import torch; print(torch.cuda.is_available());"
