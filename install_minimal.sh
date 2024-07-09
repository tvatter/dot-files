#!/bin/bash

#### Upgrade default install
sudo apt update
sudo apt upgrade
sudo apt install -y wget curl apt-transport-https software-properties-common vim

#### ZSH
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed -e 's/^\s*chsh -s/sudo chsh -s/g' -e 's/^\s*env\szsh.*$/#/g')"
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

#### Dotfiles
cd zsh; for f in *; do rm -rf ~/.$f; ln -s $PWD/$f ~/.$f; done; cd ..
declare -a files=(".gitconfig" ".condarc")
for file in "${files[@]}"; do rm -rf ~/$file; ln -s $PWD/$file ~/$file; done

#### Conda
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -p $HOME/miniforge3
rm Miniforge3-$(uname)-$(uname -m).sh
exec zsh
