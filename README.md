# dot-files

My various dot files to avoid wasting time on install.

## Pre-install

* Install git and xclip, create an ssh for git and add it to github:

```
sudo apt install -y git xclip
ssh-keygen -t rsa -b 4096 -C "thibault.vatter@gmail.com" -N "" -f ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
xclip -sel clip < ~/.ssh/id_rsa.pub  # -> add on github.com
```

* Install the latest graphic drivers. On a server (e.g., an AWS instance), this step can be skipped. On a computer with intel graphics (for nvidia, go to next bullet point):
```
sudo add-apt-repository ppa:oibaf/graphics-drivers
sudo apt update
sudo apt dist-upgrade
```

* Or if you have an nvidia GPU (XYZ is the latest driver compatible with your GPU):


```
sudo apt purge nvidia*
sudo apt update
sudo apt install nvidia-XYZ
```

## Install

* Clone the repo:

```
git clone https://github.com/tvatter/dot-files.git
cd ~/dot-files
```

* Update the line for the latest RStudio version (line 125) and run the install script:

```
chmod +x install.sh
./install.sh
```

Alternatively, a minimal version, without the theme and graphical applications (e.g., for use on a server), can be installed via:

```
chmod +x install_minimal.sh
./install_minimal.sh
```

In this case, the theme for the gnome terminal can be further installed using:

```
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized; ./install.sh -s dark --install-dircolors; cd ..; rm -rf gnome-terminal-colors-solarized
```

## Post-install

* Make zsh the default shell (need to log out and log back in):

```
chsh -s $(which zsh)
```

Note that this step sometimes requires `sudo`.

* If the version of clang Because some clang tools are installed with their version number, you probably need:

```
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-6.0 100
```

* Similarly, you may need to update line 246 in `init.vim`:

```
let g:ncm2_pyclang#library_path = 'path/to/llvm/lib
```

* To be able to use autocomplete with R, it is necessary to:

  * Disactivate ncm-R by commenting line 71 of `init.vim` (`Plug 'gaalcaras/ncm-R'`)
  * Open an R file and launch an R terminal (`<local leader>rf`, that is `,rf` by
    default or `<space>rf` with my custom mapping)
  * Wait until Nvim-R has built the required `*` files
  * Reactivate ncm-R by uncommenting the line above and close nvim


* Update make command in Renviron (either `/etc/R/Renviron` or 
`/usr/lib/R/etc/Renviron`, see `R.home()`) to compile on multiple cores:

```
MAKE=${MAKE-'make -j 8'}
```

### Additional

* Install the lastpass chrome extension and log into it
* Complete dropbox install

```
dropbox start
```

* Add dropbox as a startup application
    * In the "name" field, type `Dropbox`.
    * In the "command" field, type `/home/{your-username}/.dropbox-dist/dropboxd`.

* Update the theme in the gnome tweak tool
    * Applications: `Arc-Dark`
    * Icons: `Moka`
* Add the terminal as a startup application
    * In the "name" field, type `Terminal`.
    * In the "command" field, type `gnome-terminal`.

### Power-saving on a laptop

* Deactivate bluetooth. If `/etc/rc.local` already exists, simply 
add `rfkill block bluetooth` before the line starting with `exit 0`. 18.04+ users 
who don't naturally have a `/etc/rc.local` need to create one and make it executable.

```
sudo install -b -m 755 /dev/stdin /etc/rc.local << EOF
#!/bin/sh
rfkill block bluetooth
exit 0
EOF
```

* Install `powertop`, run the calibration and then let `powertop` take measures for a while on battery.

```
sudo apt install powertop
sudo powertop --calibrate --htlm
sudo powertop --htlm
```

* You can then verify that `powertop` has enough measurements by running `sudo powertop --auto-tune`. If it runs without 
issue, you can then add auto-tune as a service.

```
cat << EOF | sudo tee /etc/systemd/system/powertop.service
[Unit]
Description=PowerTOP auto tune

[Service]
Type=idle
Environment="TERM=dumb"
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable powertop.service
```

* Install and run `tlp`.

```
sudo apt install tlp
sudo systemctl status tlp
sudo tlp start
sudo tlp-stat -s 
```

* Follow [this suggestion](https://askubuntu.com/questions/1029474/ubuntu-18-04-dell-xps13-9370-no-longer-suspends-on-lid-close/1036122#1036122) 
is the battery is drained too fast even when the lid is closed.

### TODO
 
  * On OSX: 
      * Use old commit to create install script
      * check that `ale_cpp_clang_executable` use homebrew's clang
      * verify install clangd [(for ALE)](https://github.com/w0rp/ale/blob/master/doc/ale-cpp.txt)
  * [Autoformat](https://github.com/Chiel92/vim-autoformat)
  * Python (explore better python-syntax and pymode)  
  * Octave
  * [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim) and [example use](https://github.com/kadekillary/init.vim/blob/master/init.vim)
  

