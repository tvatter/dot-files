# How to install CUDA

## Nvidia drivers install

Remove nvidia drivers

```bash
sudo apt autoremove nvidia* --purge
```

Check the ones that are available

```bash
ubuntu-drivers devices
```

Then, either `sudo apt install some_specific_driver`, or use the recommended one from the list

```bash
sudo ubuntu-drivers autoinstall
```

## CUDA install

Done through Pytorch
