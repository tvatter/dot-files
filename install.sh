#!/bin/bash

#### Upgrade default install
sudo apt update
sudo apt upgrade
sudo apt install -y xclip wget curl apt-transport-https software-properties-common

#### Ubuntu theme
sudo add-apt-repository -y ppa:noobslab/themes
sudo add-apt-repository -y ppa:noobslab/icons
sudo apt update
sudo apt install -y gnome-tweak-tool arc-theme arc-icons moka-icon-theme

#### Gnome terminal theme
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized; ./install.sh -s dark --install-dircolors; cd ..; rm -rf gnome-terminal-colors-solarized

#### Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install -y google-chrome-stable

#### Dropbox
wget -c 'https://linux.dropbox.com/packages/dropbox.py'
chmod +x dropbox.py; mv dropbox.py ~/.dropbox.py
sudo rm -rf /usr/bin/dropbox; sudo ln -s ~/.dropbox.py /usr/bin/dropbox
dropbox autostart -y
dropbox update

#### Skype
curl https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
echo "deb https://repo.skype.com/deb stable main" | sudo tee /etc/apt/sources.list.d/skypeforlinux.list
sudo apt update
sudo apt install -y skypeforlinux

#### Zoom
mkdir -p zoom; cd zoom
wget -c https://zoom.us/client/latest/zoom_amd64.deb
sudo dpkg -i zoom*.deb
sudo apt install -f -y 
cd ..; rm -rf zoom

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
declare -a files=(".R" ".gitconfig")
for file in "${files[@]}"; do rm -rf ~/$file; ln -s $PWD/$file ~/$file; done

#### C++
sudo apt install -y build-essential
sudo apt install -y libclang-dev clang clang-tools
sudo apt install -y cmake
sudo apt install -y libboost-dev libeigen3-dev 
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-6.0 100

#### TeX
sudo apt install -y texlive-full

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
sudo apt install -y python3 python3-pip python3-setuptools
pip3 install wheel pynvim unidecode jedi

#### Neovim
sudo add-apt-repository -y  ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qall > /dev/null
mkdir -p ~/.config/nvim/after
mkdir -p ~/.config/nvim/after/syntax
mkdir -p ~/.config/nvim/after/syntax/tex
mkdir -p downloads
cd downloads
wget http://www.drchip.org/astronaut/vim/vbafiles/amsmath.vba.gz
wget http://www.drchip.org/astronaut/vim/vbafiles/array.vba.gz
wget http://www.drchip.org/astronaut/vim/vbafiles/lstlisting.vba.gz
wget http://www.drchip.org/astronaut/vim/vbafiles/moreverb.vba.gz
nvim amsmath.vba.gz +UseVimball +qall > /dev/null
nvim array.vba.gz +UseVimball +qall > /dev/null
nvim lstlisting.vba.gz +UseVimball +qall > /dev/null
nvim moreverb.vba.gz +UseVimball +qall > /dev/null
cd ..
rm -rf downloads

#### Hugo
sudo apt install -y hugo

#### Mendeley
mkdir -p mendeley; cd mendeley
wget -c https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
sudo dpkg -i mendeley*
sudo apt install -f -y 
cd ..; rm -rf mendeley

#### Texmaker
sudo apt install -y texmaker

#### Rstudio
sudo apt install -y gdebi-core libjpeg62
mkdir -p rstudio; cd rstudio
wget -c https://s3.amazonaws.com/rstudio-ide-build/desktop/bionic/amd64/rstudio-1.2.1335-amd64.deb 
sudo gdebi --non-interactive rstudio*
cd ..; rm -rf rstudio

#### Libreoffice
sudo apt install -y libreoffice
