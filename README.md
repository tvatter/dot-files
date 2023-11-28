# dot-files

My various dot files to avoid wasting time on install.

## Pre-install

- Install git and xclip, create an ssh for git and add it to github:

```
sudo apt install -y git xclip
ssh-keygen -t rsa -b 4096 -C "thibault.vatter@gmail.com" -N "" -f ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
xclip -sel clip < ~/.ssh/id_rsa.pub  # -> add on github.com
```

## Install

- Clone the repo:

```bash
git clone https://github.com/tvatter/dot-files.git
cd ~/dot-files
```

- Update the line for the latest RStudio and ubuntu version (for cmake) and run the install script:

```bash
chmod +x install.sh
./install.sh
```

Alternatively, a minimal version, without the theme and graphical applications (e.g., for use on a server), can be installed via:

```bash
chmod +x install_minimal.sh
./install_minimal.sh
```

In this case, the theme for the gnome terminal can be further installed using:

```bash
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized; ./install.sh -s dark --install-dircolors; cd ..; rm -rf gnome-terminal-colors-solarized
```

## Post-install

- Enable [rootless Docker](https://docs.docker.com/engine/security/rootless/) by running `dockerd-rootless-setuptool.sh install`
- Make zsh the default shell (need to log out and log back in):

```bash
chsh -s $(which zsh)
```

Note that this step sometimes requires `sudo`.

- Update make command in Renviron (either `/etc/R/Renviron` or
  `/usr/lib/R/etc/Renviron`, see `R.home()`) to compile on multiple cores:

```text
MAKE=${MAKE-'make -j 8'}
```

- Install the bitwarden brave extension and log into it
- Complete dropbox install

```bash
dropbox start
```

- Add dropbox as a startup application
    - In the "name" field, type `Dropbox`.
    - In the "command" field, type `/home/{your-username}/.dropbox-dist/dropboxd`.
- Add terminal as startup application
- Change the theme:
    - In `Tweaks`, set the materia or arc theme as well as Jetbrains font
- Update font in the `gnome-terminal`:
    - Go to `Edit/preferences/profiles/custom font`
    - Use `JetBrainsMono-Regular`

### Power-saving on a laptop

- Deactivate bluetooth. If `/etc/rc.local` already exists, simply
  add `rfkill block bluetooth` before the line starting with `exit 0`. 18.04+ users
  who don't naturally have a `/etc/rc.local` need to create one and make it executable.

```bash
sudo install -b -m 755 /dev/stdin /etc/rc.local << EOF
#!/bin/sh
rfkill block bluetooth
exit 0
EOF
```

- Install `powertop`, run the calibration and then let `powertop` take measures for a while on battery.

```bash
sudo apt install powertop
sudo powertop --calibrate --htlm
sudo powertop --htlm
```

- You can then verify that `powertop` has enough measurements by running `sudo powertop --auto-tune`. If it runs without
  issue, you can then add auto-tune as a service.

```bash
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

- Install and run `tlp`.

```bash
sudo apt install tlp
sudo systemctl status tlp
sudo tlp start
sudo tlp-stat -s 
```

- Follow [this suggestion](https://askubuntu.com/questions/1029474/ubuntu-18-04-dell-xps13-9370-no-longer-suspends-on-lid-close/1036122#1036122)
  is the battery is drained too fast even when the lid is closed.

## vscode via ssh

- On the host machine:
    - Install the required X11 packages by doing `sudo apt install x11-apps`
    - Configure X11 forwarding `sudo cat /etc/ssh/sshd_config |grep -i X11Forwarding` should return something like `X11Forwarding yes`
    If not, then edit `/etc/ssh/sshd_config` accordingly and restart via `sudo service ssh restart`.
- On the local machine:
    - Add `"terminal.integrated.env.linux": {"DISPLAY":"localhost:10.0"}` in `settings.json`
    - Connect to the host machine via ssh using `-X` in a local terminal (OUTSIDE VSCODE!!!).
    This will always be needed, see [this issue](https://github.com/microsoft/vscode-remote-release/issues/267#issuecomment-535403394).
    - In vscode:
        - Add the host as a new ssh host using microsoft's extension (`ms-vscode-remote.remote-ssh`).
        - Make sure that `ForwardX11 yes` is added to `~/.ssh/config` (or location of ssh's config) for this host.
      This can be done e.g. with `ms-vscode-remote.remote-ssh-edit`.
        - Connect to the host
