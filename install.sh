#!/bin/bash

#### Upgrade default install
sudo apt update
sudo apt upgrade
sudo apt install -y wget curl apt-transport-https software-properties-common openssh-server vim

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
cd vscode; mkdir -p ~/.config/Code/User; for f in *; do rm -rf ~/.config/Code/User/$f; ln -s $PWD/$f ~/.config/Code/User; done; cd ..
declare -a files=(".R" ".gitconfig" ".condarc" ".radian_profile" ".pylintrc")
for file in "${files[@]}"; do rm -rf ~/$file; ln -s $PWD/$file ~/$file; done

#### C++
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null # check ubuntu version!!
sudo apt-get update
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
sudo apt install -y libcurl4-openssl-dev libssl-dev # for tidyverse packagews
sudo apt install -y libxml2-dev libfontconfig1-dev # for tidyverse packagews
sudo apt install -y libgsl-dev  # for VineCopula 
sudo apt install -y xorg libx11-dev libglu1-mesa-dev libfreetype6-dev # for rgl
Rscript --vanilla -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
Rscript --vanilla -e 'install.packages(c("lintr", "styler", "languageserver", "BH", "RcppEigen", "tidyverse", "blogdown", "kableExtra", "devtools","RColorBrewer", "ggthemes"), lib = Sys.getenv("R_LIBS_USER"), repo = "https://cloud.r-project.org/")'

#### Python
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda.sh
bash conda.sh -b -p $HOME/miniconda
rm conda.sh
exec zsh
conda update -n base -c defaults conda
conda install -c conda-forge pylint yapf jedi unidecode wheel isort
conda install -c conda-forge numpy scipy scikit-learn pandas
conda install -c conda-forge matplotlib seaborn
conda install -c conda-forge ipython build
# conda install -c conda-forge radian # a better console, see https://github.com/randy3k/radian

#### Hugo
sudo apt install -y hugo

#### Pandoc
sudo apt install -y pandoc

#### npm and stuff
# sudo apt install -y npm
# sudo npm install remark remark-lint textlint --global

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
wget -c https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.4.1717-amd64.deb 
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
