#!/bin/bash

#### Upgrade default install
sudo apt update
sudo apt upgrade
sudo apt install -y wget curl apt-transport-https software-properties-common openssh-server vim

#### Activate firewall
sudo ufw allow ssh
sudo ufw enable

#### Ubuntu theme
sudo apt install -y gnome-tweaks arc-theme materia-gtk-theme

#### Gnome terminal theme
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized; ./install.sh -s dark --install-dircolors; cd ..; rm -rf gnome-terminal-colors-solarized
wget https://download.jetbrains.com/fonts/JetBrainsMono-1.0.3.zip
sudo unzip JetBrainsMono-1.0.3.zip -d /usr/share/fonts/
fc-cache -f -v
rm JetBrainsMono-1.0.3.zip

#### Brave
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
sudo apt update
sudo apt install -y brave-browser

# #### Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
sudo apt update
sudo apt install -y google-chrome-stable

#### Dropbox
wget -c 'https://linux.dropbox.com/packages/dropbox.py'
chmod +x dropbox.py; mv dropbox.py ~/.dropbox.py
sudo rm -rf /usr/bin/dropbox; sudo ln -s ~/.dropbox.py /usr/bin/dropbox
dropbox autostart -y
dropbox update

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
declare -a files=(".R" ".gitconfig" ".condarc" ".pylintrc", ".Rprofile")
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

#### TeX
sudo apt install -y texlive-full

#### R
sudo apt install software-properties-common dirmngr
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc > /dev/null
echo "deb [arch=amd64] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | sudo tee /etc/apt/sources.list.d/cran_r.list > /dev/null
sudo apt update
sudo apt install -y r-base r-base-dev

#### r2u
wget -qO- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc | sudo tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc > /dev/null
echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/cranapt.list > /dev/null
echo "Package: *" | sudo tee /etc/apt/preferences.d/99cranapt
echo "Pin: release o=CRAN-Apt Project" | sudo tee -a /etc/apt/preferences.d/99cranapt
echo "Pin: release l=CRAN-Apt Packages" | sudo tee -a /etc/apt/preferences.d/99cranapt
echo "Pin-Priority: 700"  | sudo tee -a /etc/apt/preferences.d/99cranapt
Rscript --vanilla -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
Rscript --vanilla -e 'install.packages(c("lintr", "styler", "languageserver", "tidyverse", "blogdown", "kableExtra", "devtools","RColorBrewer", "ggthemes"), lib = Sys.getenv("R_LIBS_USER"))'

#### Python
wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
bash Mambaforge-Linux-x86_64.sh -b -p $HOME/mambaforge
rm Mambaforge-Linux-x86_64.sh
exec zsh
mamba install pylint yapf build jedi unidecode wheel isort
mamba install numpy scipy matplotlib pandas scikit-learn seaborn 
mamba install ipython jupyter
mamba update --all
# mamba install rpy2 r-tidyverse r-languageserver r-devtools r-lintr
# mamba install r-blogdown r-kableExtra r-ggthemes
# mamba update --all


#### Hugo
sudo apt install -y hugo

#### Pandoc
sudo apt install -y pandoc

#### npm and stuff
# sudo apt install -y npm
# sudo npm install -g n
# sudo n lts
# sudo n prune
# sudo npm install remark remark-lint textlint --global

#### Mendeley
# mkdir -p mendeley; cd mendeley
# wget -c https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
# # TODO see https://serverfault.com/questions/250224/how-do-i-get-apt-get-to-ignore-some-dependencies
# sudo dpkg -i mendeley*
# sudo apt install -y gconf2 python2 python-is-python3
# sudo apt install -f -y 
# cd ..; rm -rf mendeley

# #### Texmaker
sudo apt install -y texmaker

#### Rstudio
sudo apt install -y gdebi-core libjpeg62
mkdir -p rstudio; cd rstudio
wget -c https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.09.1-494-amd64.deb 
sudo gdebi --non-interactive rstudio*
cd ..; rm -rf rstudio

#### Libreoffice
sudo apt install -y libreoffice

#### VLC
sudo apt install -y vlc

#### nordvpn
wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh

wget -qO - "https://repo.nordvpn.com/gpg/nordvpn_public.asc" | sudo tee /etc/apt/trusted.gpg.d/nordvpn_public.asc > /dev/null
echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" | sudo tee /etc/apt/sources.list.d/nordvpn.list > /dev/null
sudo apt update
sudo apt install -y nordvpn
# sudo apt install -y openvpn ca-certificates unzip screen
# cd /etc/openvpn
# sudo wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
# sudo unzip ovpn.zip
# sudo rm ovpn.zip
# cd ~/dot-files

#### VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"| sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt update
sudo apt install code


