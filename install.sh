## Upgrade default install ----------

sudo apt update
sudo apt upgrade
sudo apt install -y wget curl apt-transport-https software-properties-common

#### Ubuntu theme
sudo add-apt-repository ppa:noobslab/themes
sudo add-apt-repository ppa:noobslab/icons
sudo apt update
sudo apt install -y gnome-tweak-tool arc-theme arc-icons moka-icon-theme

#### Solarized theme
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized; ./install.sh -s dark --install-dircolors; cd ..; rm -rf gnome-terminal-colors-solarized

## Web ----------

#### Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install -y google-chrome-stable

#### Communication 
sudo apt install -y skypeforlinux zoom

## Terminal

#### ZSH
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

#### Dotfiles
cd zsh; for f in .*; do rm ~/$f; ln -s $PWD/$f ~/; done; cd ..
cd vim; mkdir -p ~/.config/nvim; for f in *; do rm ~/.config/nvim/$f; ln -s $PWD/$f ~/.config/nvim; done; cd ..
declare -a files=(".R" ".gitconfig")
for file in "${files[@]}"; do; rm -rf ~/$file; ln -s ~/dot-files/$file ~/$file; done

## Programming ----------

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
Rscript --vanilla -e 'install.packages(c("lintr", "styler"), repo = "https://cloud.r-project.org/")'
Rscript --vanilla -e 'install.packages(c("BH", "RcppEigen", "tidyverse", "blogdown", "kableExtra", "devtools","RColorBrewer", "ggthemes"), repo = "https://cloud.r-project.org/")'
Rscript --vanilla -e 'devtools::install_github("jimhester/lintr")'

#### Python
sudo apt install -y python3 python3-pip python3-setuptools
pip3 install wheel pynvim unidecode jedi

#### Neovim
sudo apt update
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt install -y neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall
mkdir -p ~/.config/nvim/after
mkdir -p ~/.config/nvim/after/syntax
mkdir -p ~/.config/nvim/after/syntax/tex
mkdir -p downloads
cd downloads
wget http://www.drchip.org/astronaut/vim/vbafiles/amsmath.vba.gz
wget http://www.drchip.org/astronaut/vim/vbafiles/array.vba.gz
wget http://www.drchip.org/astronaut/vim/vbafiles/lstlisting.vba.gz
wget http://www.drchip.org/astronaut/vim/vbafiles/moreverb.vba.gz
nvim amsmath.vba.gz +UseVimball
nvim array.vba.gz +UseVimball
nvim lstlisting.vba.gz +UseVimball
nvim moreverb.vba.gz +UseVimball
cd ..
rm -rf downloads

#### Web
sudo apt install -y hugo

