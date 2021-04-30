#!/bin/bash

#### Upgrade default install
sudo apt update
sudo apt upgrade
sudo apt install -y wget curl apt-transport-https software-properties-common openssh-server

#### Activate firewall
sudo ufw allow ssh
sudo ufw enable

#### Ubuntu theme
#sudo add-apt-repository -y ppa:noobslab/themes
#sudo add-apt-repository -y ppa:noobslab/icons
#sudo apt update
sudo apt install -y gnome-tweak-tool #arc-theme arc-icons moka-icon-theme

#### Gnome terminal theme
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized; ./install.sh -s dark --install-dircolors; cd ..; rm -rf gnome-terminal-colors-solarized
wget https://download.jetbrains.com/fonts/JetBrainsMono-1.0.3.zip
sudo unzip JetBrainsMono-1.0.3.zip -d /usr/share/fonts/
fc-cache -f -v
rm JetBrainsMono-1.0.3.zip

#### Brave
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser

# #### Chrome
# wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
# echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
# sudo apt update
# sudo apt install -y google-chrome-stable

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
cd vscode; mkdir -p ~/.config/Code/User; for f in *; do rm -rf ~/.config/Code/User/$f; ln -s $PWD/$f ~/.config/Code/User; done; cd ..
declare -a files=(".jupyter" ".R" ".gitconfig" ".condarc" ".radian_profile" ".pylintrc")
for file in "${files[@]}"; do rm -rf ~/$file; ln -s $PWD/$file ~/$file; done

#### C++
sudo apt install -y build-essential
sudo apt install -y libclang-dev clang clang-tools clang-tidy clang-format
sudo apt install -y cmake doxygen
sudo apt install -y libboost-dev libeigen3-dev 

#### TeX
sudo apt install -y texlive-full

#### R
sudo add-apt-repository -y ppa:marutter/rrutter4.0
sudo apt update
sudo apt install -y r-base r-base-dev
sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev  # for tidyverse packagews
sudo apt install -y libgsl-dev  # for VineCopula 
sudo apt install -y xorg libx11-dev libglu1-mesa-dev libfreetype6-dev # for rgl
Rscript --vanilla -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
Rscript --vanilla -e 'install.packages(c("lintr", "styler", "languageserver", "BH", "RcppEigen", "tidyverse", "blogdown", "kableExtra", "devtools","RColorBrewer", "ggthemes"), lib = Sys.getenv("R_LIBS_USER"), repo = "https://cloud.r-project.org/")'
pip install -U radian # a better console, see https://github.com/randy3k/radian
# Rscript --vanilla -e 'devtools::install_github("jimhester/lintr", lib = Sys.getenv("R_LIBS_USER"))'

#### Python
# sudo apt install -y python3 python3-pip python3-setuptools
# pip3 install wheel pynvim unidecode jedi
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda.sh
bash conda.sh -b -p $HOME/miniconda
rm conda.sh
exec zsh
conda update -n base -c defaults conda
conda install pylint yapf jedi setuptools wheel
conda create --name vim python=3.8.2
conda activate vim
conda install -c conda-forge pynvim
conda install setuptools wheel unidecode jedi flake8 autopep8 isort pylint
# conda install jupyter jupyter_contrib_nbextensions
#conda create --name vim --file conda_spec.txt

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
mkdir -p ~/.config/nvim/spell
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

#### Pandoc
sudo apt install -y pandoc

#### npm and stuff
sudo apt install -y npm
sudo npm install remark remark-lint textlint --global

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

#### VLC
sudo apt install -y vlc

#### nordvpn
sudo wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
sudo dpkg -i nordvpn-release_1.0.0_all.deb
sudo apt update
sudo apt install -y nordvpn
sudo rm nordvpn-release_1.0.0_all.deb
# sudo apt install -y openvpn ca-certificates unzip screen
# cd /etc/openvpn
# sudo wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
# sudo unzip ovpn.zip
# sudo rm ovpn.zip
# cd ~/dot-files

#### VS Code
sudo wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt install code

#### signal
sudo wget -q https://updates.signal.org/desktop/apt/keys.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main"
sudo apt update && sudo apt install signal-desktop
