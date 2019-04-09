# dot-files

My various dot files to avoid wasting time on install.

* Install the latest graphic drivers using either (e.g., on a computer with intel graphics)

```
sudo add-apt-repository ppa:oibaf/graphics-drivers
sudo apt update
sudo apt dist-upgrade
```

or if you have an nvidia GPU (XYZ is the latest driver compatible with your GPU)

```
sudo apt purge nvidia*
sudo apt update
sudo apt install nvidia-XYZ
```

* Install/configure git and clone the repo

```
sudo apt install -y git
git clone https://github.com/tvatter/dot-files.git
cd ~/dot-files
```

* Update the line for the latest RStudio version (line 125) and run the install script

```
chmod +x install.sh
./install.sh
```

* Install the lastpass chrome extension and log into it
* Create an ssh for git and add it to github:

```
ssh-keygen -t rsa -b 4096 -C "thibault.vatter@gmail.com" -N "" -f ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
xclip -sel clip < ~/.ssh/id_rsa.pub  # -> add on github.com
```

* Complete dropbox install

```
dropbox start
```

* Add dropbox as a startup application
    * In the "name" field, type `Dropbox`.
    * In the "command" field, type `/home/{your-username}/.dropbox-dist/dropboxd`.


* Update the theme in the gnome tweak tool
* Add the terminal as a startup application
    * In the "name" field, type `Terminal`.
    * In the "command" field, type `gnome-terminal`.
* If needed, desactivate bluetooth. 18.04+ users who don't naturally have a `/etc/rc.local` need to create one and make it executable

```
sudo install -b -m 755 /dev/stdin /etc/rc.local << EOF
#!/bin/sh
rfkill block bluetooth
exit 0
EOF
```

If `/etc/rc.local` already exists, simply add `rfkill block bluetooth` before the line starting with `exit 0`.

* Make zsh the default shell (need to log out and log back in):

```
chsh -s $(which zsh)
```
If it did not work, then you'll need to manually change `/etc/passwd`. 
Find the line with your username and replace `/bin/bash` by `/bin/zsh`.

* If the version of clang Because some clang tools are installed with their version number, you probably need:

```
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-6.0 100
```

* Similarly, you may need to update line 246 in `init.vim`:

```
let g:ncm2_pyclang#library_path = 'path/to/llvm/lib'
```

* To be able to use autocomplete with R, it is necessary to:

  * Disactivate ncm-R by commenting line 71 of `init.vim` (`Plug 'gaalcaras/ncm-R'`)
  * Open an R file and launch an R terminal (`<local leader>rf`, that is `,rf` by
    default or `<space>rf` with my custom mapping)
  * Wait until Nvim-R has built the required `omni_*` files
  * Reactivate ncm-R by uncommenting the line above and close nvim


* Update make command in Renviron (either `/etc/R/Renviron` or 
`/usr/lib/R/etc/Renviron`, see `R.home()`) to compile on multiple cores:

```
MAKE=${MAKE-'make -j 8'}
```

* If tensorflow is used on GPU, the following lines need to be added to `.profile`:

```
export CUDA_HOME=usr/local/cuda10.0
export PATH=${CUDA_HOME}/bin:${PATH}
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
```

* Install `KindleGen`

```
mkdir -p kindlegen; cd kindlegen
wget http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz
tar -zxvf kindlegen_linux_2.6_i386_v2_9.tar.gz
cp kindlegen ~/
sudo ln -s ~/kindlegen /usr/bin/kindlegen 
cd ..; rm -rf kindlegen
```

* Install `https://github.com/schemen/m2em`


### TODO
 
  * On OSX: 
      * Use old commit to create install script
      * check that `ale_cpp_clang_executable` use homebrew's clang
      * verify install clangd [(for ALE)](https://github.com/w0rp/ale/blob/master/doc/ale-cpp.txt)
  * [Autoformat](https://github.com/Chiel92/vim-autoformat)
  * Python (explore better python-syntax and pymode)  
  * Octave
  * [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim) and [example use](https://github.com/kadekillary/init.vim/blob/master/init.vim)
  

