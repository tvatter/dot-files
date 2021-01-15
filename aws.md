# Configuration steps for ubuntu 18.04, rstudio, and tensorflow 2

## Instance config

* Use the [RStudio AMI by Louis Alette](http://www.louisaslett.com/RStudio_AMI/)
* Add storage (at least 80-100Gb)
* Configure security group to allow SSH (port 22) and HTTP (port 80)

## System config

### Pre-install

* Log-in as `ubuntu`:
  * Add `sudo` powers and a password to the `rstudio` user.
  * Log-out and log back in using the `rstudio` user.
* Follow the pre-install steps from [README.md](https://github.com/tvatter/dot-files/blob/master/README.md), BUT:
  * Use `cat ~/.ssh/id_rsa.pub` to get the SSH key for GitHub (`xclip` doesn't work on AWS for some reason)
  * Skip the drivers steps

### Install

* Follow the install and post-install steps from [README.md](https://github.com/tvatter/dot-files/blob/master/README.md).
* Follow the steps from the [tensorflow website](https://www.tensorflow.org/install/gpu) to properly re-install/upgrade CUDA (read until the end!!!):

```
# Add NVIDIA package repositories
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.1.243-1_amd64.deb
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo dpkg -i cuda-repo-ubuntu1804_10.1.243-1_amd64.deb
sudo apt-get update
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt install ./nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt-get update

# Install NVIDIA driver
sudo apt-get install --no-install-recommends nvidia-driver-430
# Reboot. Check that GPUs are visible using the command: nvidia-smi

# Install development and runtime libraries (~4GB)
sudo apt-get install --no-install-recommends \
    cuda-10-1 \
    libcudnn7=7.6.4.38-1+cuda10.1  \
    libcudnn7-dev=7.6.4.38-1+cuda10.1


# Install TensorRT. Requires that libcudnn7 is installed above.
sudo apt-get install -y --no-install-recommends libnvinfer6=6.0.1-1+cuda10.1 \
    libnvinfer-dev=6.0.1-1+cuda10.1 \
    libnvinfer-plugin6=6.0.1-1+cuda10.1

```

Note that I can't remember exactly the steps here, but before installing the NVIDIA driver, I removed my old drivers via:

```
sudo apt purge nvidia*
sudo apt update
```

Then, the install the NVIDIA driver failed as the old ones weren't properly uninstalled, BUT when install cuda-10-1, it suggested to upgrade the drivers to nvidia-driver-440, and it just worked.

### Tensorflow install

* Create and activate a conda environment for tensorflow (cloned from the environment configured for vim, as it already has a few useful libraries installed):

```
conda create --name tensorflow --clone vim
conda activate tensorflow
```

* Install tensorflow, keras and verify the install:

```
pip install --upgrade pip
pip install --upgrade tensorflow keras
python -c "import tensorflow as tf;print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```

* In R, install tensorflow, keras, and verify the install:

```
install.packages(c("tensorflow", "keras"))
library(reticulate)
py_config() # (Answer no if asked) This should point toward the conda environment with tensorflow!
library(tensorflow)
tf$constant("Hellow Tensorflow") # A bunch of printed stuff with success/GPU info!
```
