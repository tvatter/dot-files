# dot-files

My various dot files to avoid wasting time on install.


### Installs

[Install dropbox first (sync of files can take a long time)](https://www.dropbox.com/install-linux)


#### Ubuntu

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
sudo apt install clang-tools
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

Because some clang tools are installed with their version number, you probably need:

```
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-6.0 100
```

Install solarized theme for the GNOME terminal:

```
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized
./install.sh
```

And just follow the instructions.

#### OSX

Install homebrew:

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install caskroom/cask/brew-cask
brew tap caskroom/cask
```

Install required software:

```
brew install wget
brew install git
brew install gcc
brew install cmake
brew install llvm
brew cask install mactex
brew install r
brew install python3
brew install neovim
brew install zsh-syntax-highlighting
```

Check whether you can follow the instructions for the solarized theme on ubuntu,
otherwise:

```
brew cask install iterm2
```

And get a better color theme for iTerm2:

  * [Solarized Dark theme](https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Solarized%20Dark%20-%20Patched.itermcolors) (patched version to fix the bright black value)
  * [Solarized Light theme](https://raw.githubusercontent.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Light.itermcolors)
  * [More themes @ iterm2colorschemes](http://iterm2colorschemes.com/)

To install:

* Just save it somewhere and open the file(s). The color settings will be imported into iTerm2. 
  * Apply them in iTerm through iTerm → preferences → profiles → colors → load presets. 
  * You can create a different profile other than `Default` if you wish to do so.

From now on, use `iTerm2` instead of the default `terminal`
It has better color fidelity than the built in, so your themes will look better.

Run brew doctor and make sure that everything is OK (e.g., especially regarding
the path):

```
brew doctor
```


#### Both

```
pip3 install pynvim
pip3 install unidecode
pip3 install jedi
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

In `zshrc`, you can comment or update lines 19 and 20:

```
export PATH=/home/tvatter/anaconda3/bin:/usr/local/cuda-10.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
```


Link required files:

```
ln -nfs ${PWD}/functions.zsh ~/functions.zsh
ln -nfs ${PWD}/zshrc ~/.zshrc
ln -nfs ${PWD}/zshrc.zni ~/.zshrc.zni
```

Verify that the plugins `zsh-autosuggestions` and `zsh-syntax-highlighting` are in `~/.oh-my-zsh/plugins`. If not, then install them using:

```
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting
~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```


#### Ubuntu

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


#### OSX

Make zsh the default shell by using

```
chsh -s /bin/zsh
```

If it does's work, change manually using the menus.

Run brew doctor and make sure that everything is OK (e.g., especially regarding
the path):

```
brew doctor
```

### Configuring NEOVIM

Install plug-in manager:

```
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Update line 246 in `init.vim`:

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

  * Disactivate ncm-R by commenting line 71 of `init.vim` (`Plug 'gaalcaras/ncm-R'`)
  * Open an R file and launch an R terminal (`<leader>rf`, that is `\rf` by
    default or `<space>rf` with my custom mapping)
  * Wait until Nvim-R has built the required `omni_*` files
  * Close nvim
  * Reactivate ncm-R by uncommenting the line above

Note that the `rmarkdown` and `lintr` packages are required to get, respectively, Rmarkdown support and asynchronous linting.

### Configuring R

Update make command in Renviron (either `/etc/R/Renviron` or 
`/usr/lib/R/etc/Renviron`, see `R.home()`) to compile on multiple cores:

```
MAKE=${MAKE-'make -j 8'}
```

Link Makevars:

```
ln -nfs ${PWD}/Makevars ~/.R/Makevars
```

Install needed packages:

```
install.packages('rmarkdown')
install.packages('lintr')
```

If tensorflow is used on GPU, the following lines need to be added to `.profile`:

```
export CUDA_HOME=usr/local/cuda10.0
export PATH=${CUDA_HOME}/bin:${PATH}
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
```

### Configuring VNC

Follow
 
  * https://help.ubuntu.com/community/VNC/Servers#vino
  * https://linuxconfig.org/ubuntu-remote-desktop-18-04-bionic-beaver-linux

```
gsettings set org.gnome.Vino require-encryption false
gsettings reset org.gnome.Vino network-interface
```

### TODO
 
  * On OSX: 
      * check that `ale_cpp_clang_executable` use homebrew's clang
      * verify install clangd [(for ALE)](https://github.com/w0rp/ale/blob/master/doc/ale-cpp.txt)
  * [Autoformat](https://github.com/Chiel92/vim-autoformat)
  * Python (explore better python-syntax and pymode)  
  * Octave
  * [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim) and [example use](https://github.com/kadekillary/init.vim/blob/master/init.vim)
  
