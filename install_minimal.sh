#!/bin/bash

#### Upgrade default install
sudo apt update
sudo apt upgrade
sudo apt install -y wget curl apt-transport-https software-properties-common openssh-server vim

#### ZSH
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed -e 's/^\s*chsh -s/sudo chsh -s/g' -e 's/^\s*env\szsh.*$/#/g')"
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

#### Dotfiles
cd zsh; for f in *; do rm -rf ~/.$f; ln -s $PWD/$f ~/.$f; done; cd ..
declare -a files=(".gitconfig")
for file in "${files[@]}"; do rm -rf ~/$file; ln -s $PWD/$file ~/$file; done

#### C++
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null # check ubuntu version!!
sudo apt-get update
sudo rm /usr/share/keyrings/kitware-archive-keyring.gpg
sudo apt-get install kitware-archive-keyring
sudo apt install -y build-essential
sudo apt install -y libclang-dev clang clang-tools clang-tidy clang-format
sudo apt install -y cmake doxygen
sudo apt install -y libboost-dev libeigen3-dev 

#### Python
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -p $HOME/miniforge3
rm Miniforge3-$(uname)-$(uname -m).sh
exec zsh
conda config --add channels conda-forge
conda config --set channel_priority strict
mamba install python=3.11 build unidecode wheel isort ruff mypy pytest
mamba install numpy scipy matplotlib pandas scikit-learn seaborn 
mamba install ipython jupyter
mamba update --all
