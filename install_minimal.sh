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
declare -a files=(".R" ".gitconfig" ".condarc" ".radian_profile" ".pylintrc")
for file in "${files[@]}"; do rm -rf ~/$file; ln -s $PWD/$file ~/$file; done
find . -type f -exec sed -i "s/tvatter/$USER/g" {} \;

#### C++
sudo apt install -y build-essential
sudo apt install -y libclang-dev clang clang-tools clang-tidy
sudo apt install -y cmake
sudo apt install -y libboost-dev libeigen3-dev 
# sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-6.0 100

#### R
sudo add-apt-repository -y ppa:marutter/rrutter4.0
sudo apt update
sudo apt install -y r-base r-base-dev
sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev  # for tidyverse packages
Rscript --vanilla -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
Rscript --vanilla -e 'install.packages(c("lintr", "styler", "languageserver", "tidyverse", "devtools"), lib = Sys.getenv("R_LIBS_USER"), repo = "https://cloud.r-project.org/")'
pip install -U radian # a better console, see https://github.com/randy3k/radian

#### Python
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda.sh
bash conda.sh -b -p $HOME/miniconda
rm conda.sh
exec zsh
conda create --name vim python=3.7.3
conda activate vim
conda install -c conda-forge pynvim
conda install setuptools wheel unidecode jedi flake8 autopep8 isort pylint
