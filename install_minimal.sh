#!/bin/bash

#### Upgrade default install
sudo apt update
sudo apt upgrade
sudo apt install -y wget curl apt-transport-https software-properties-common

#### ZSH
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed -e 's/^\s*chsh -s/sudo chsh -s/g' -e 's/^\s*env\szsh.*$/#/g')"
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

#### Dotfiles
cd zsh; for f in *; do rm -rf ~/.$f; ln -s $PWD/$f ~/.$f; done; cd ..
cd vim; mkdir -p ~/.config/nvim; for f in *; do rm -rf ~/.config/nvim/$f; ln -s $PWD/$f ~/.config/nvim; done; cd ..
declare -a files=("jupyter" ".R" ".gitconfig")
for file in "${files[@]}"; do rm -rf ~/$file; ln -s $PWD/$file ~/$file; done

#### C++
sudo apt install -y build-essential
sudo apt install -y libclang-dev clang clang-tools
sudo apt install -y cmake
sudo apt install -y libboost-dev libeigen3-dev 
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-6.0 100

#### R
sudo add-apt-repository -y ppa:marutter/rrutter3.5
sudo apt update
sudo apt install -y r-base r-base-dev
sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev  # for tidyverse packagews
sudo apt install -y libgsl-dev  # for VineCopula 
sudo apt install -y xorg libx11-dev libglu1-mesa-dev libfreetype6-dev # for rgl
Rscript --vanilla -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
Rscript --vanilla -e 'install.packages(c("lintr", "styler", "BH", "RcppEigen", "tidyverse", "blogdown", "kableExtra", "devtools","RColorBrewer", "ggthemes"), lib = Sys.getenv("R_LIBS_USER"), repo = "https://cloud.r-project.org/")'
Rscript --vanilla -e 'devtools::install_github("jimhester/lintr", lib = Sys.getenv("R_LIBS_USER"))'

#### Python
# sudo apt install -y python3 python3-pip python3-setuptools
# pip3 install wheel pynvim unidecode jedi
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda.sh
bash conda.sh -b -p $HOME/miniconda
rm conda.sh
conda create --name vim --file conda_spec.txt

#### Neovim
sudo add-apt-repository -y  ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qall > /dev/null

