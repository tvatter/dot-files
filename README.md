# dot-files

My various dot files to avoid wasting time on install.


### Installs

Install dropbox first (sync of files can take a long time):
https://www.dropbox.com/install-linux

Add repositories and update:

```
sudo apt install apt-transport-https software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
```

Install required software

```
sudo apt install xclip
sudo apt install wget
sudo apt install curl
sudo apt install git
sudo apt install gcc
sudo apt install libclang-dev 
sudo apt install clang
sudo apt install cmake
sudo apt install texlive-full
sudo apt install r-base 
sudo apt install r-base-dev
sudo apt install python-dev 
sudo apt install python-pip
sudo apt install python3-dev
sudo apt install python3-pip
sudo apt install neovim
```

```
pip3 install neovim
```


### Configuring git

Link .gitconfig:
```
ln -nfs ${PWD}/.gitconfig ~/.gitconfig
```

Add ssh key:

  * https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
  * https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account

### Configuring ZSH

Install [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh):
```
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

Link required files:
```
ln -nfs ${PWD}/functions.zsh ~/functions.zsh
ln -nfs ${PWD}/zshrc ~/.zshrc
ln -nfs ${PWD}/zshrc.zni ~/.zshrc.zni
```

Make zsh the default terminal by using `chsh -s /bin/zsh`, then log out and see
if it worked. If not, then you'll need to manually change `/etc/passwd`:
```
sudo vim /etc/passwd
```

Find the line with your username:
```
username:x:1634231:100:Your Name:/home/username:/bin/bash
```

And replace bash with zsh:
```
username:x:1634231:100:Your Name:/home/username:/bin/zsh
```

Log out and log in back for the changes to take effect.

### Configuring NEOVIM

Install plug-in manager:
```
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Update line 96 in `init.vim`:
```
let g:ncm2_pyclang#library_path = 'path/to/llvm/lib'
```


Install configuration file:
```
mkdir -p ~/.config/nvim
ln -nfs ${PWD}/init.vim ~/.config/nvim/init.vim
```

Install plug-ins:
```
nvim +PlugInstall
```

For better latex:
```
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
```

To be able to use autocomplete with R, it is necessary to:

  * Disactivate ncm-R by commenting line 30 of `init.vim` (`Plug 'gaalcaras/ncm-R'`)
  * Open an R file and launch an R terminal (`<leader>rf`, that is `\rf` by
    default)
  * Wait until Nvim-R has built the required `omni_*` files
  * Close nvim
  * Reactivate ncm-R by uncommenting the line above

### Configuring R

Update make command in Renviron (either /etc/R/Renviron or 
/usr/lib/R/etc/Renviron,see R.home()) to compile on multiple cores:
```
MAKE=${MAKE-'make -j 8'}
```

Link Makevars:
```
ln -nfs ${PWD}/Makevars ~/.R/Makevars
```

### Configuring VNC

Follow
 
  * https://help.ubuntu.com/community/VNC/Servers#vino
  * https://linuxconfig.org/ubuntu-remote-desktop-18-04-bionic-beaver-linux

```
gsettings set org.gnome.Vino require-encryption false
gsettings reset org.gnome.Vino network-interface
```
