# dotfiles

# installation of tools
```
sudo apt install bash-completion vim-tiny wireshark wine build-essential flatpak git meld fwupd
```
# set vim as default
```
sudo update-alternatives --config editor
```
# git config
```
git config --global --edit
git config credential.helper store
```

# firmware update
```
sudo fwupdmgr refresh
sudo fwupdmgr update
```

# dpkg

sort installed packages by size
```
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n
```
