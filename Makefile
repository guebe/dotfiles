.PHONY: help install links groups git vim zoxide flatpak onedrive vbox pwsh firmware size
help:
	@echo "install     ... apt install packets"
	@echo "links       ... setup soft links to config files"
	@echo "groups      ... add user to groups"
	@echo "git         ... configure git"
	@echo "vim         ... configure vim"
	@echo "zoxide      ... configure zoxide"
	@echo "flatpak     ... install flatpak"
	@echo "onedrive    ... install onedrive"
	@echo "vbox        ... install virtualbox"
	@echo "pwsh        ... install powershell"
	@echo "firmware    ... upgrade firmware"
	@echo "size        ... sort installed packets by size"

install:
	sudo apt update
	sudo apt install xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev lightdm xfce4 thunar-archive-plugin xfce4-terminal network-manager-gnome build-essential gdb atril ristretto xfce4-clipman-plugin xfce4-screenshooter xfce4-power-manager tldr bash-completion firefox-esr openscad speedcrunch libx11-dev libxft-dev pkgconf libxinerama-dev dnsutils python3-venv meld git vim zoxide fzf wireshark flatpak onedrive curl gnupg2 lsb-release dkms wget fwupd

links:
	test -e ${HOME}/.xsessionrc || ln -s ${PWD}/xsessionrc ${HOME}/.xsessionrc
	test -e ${HOME}/.vimrc || ln -s ${PWD}/vimrc ${HOME}/.vimrc

groups:
	sudo usermod -aG wireshark ${USER}
	sudo usermod -aG dialout ${USER}
	sudo usermod -aG vboxusers ${USER}

git:
	git config --global credential.helper store
	git config --global user.name "gue"
	git config --global user.email gue@debian.home

vim:
	sudo update-alternatives --set editor /usr/bin/vim.basic

zoxide:
	grep -q zoxide ${HOME}/.bashrc || zoxide init bash >> ${HOME}/.bashrc

flatpak:
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub us.zoom.Zoom org.ghidra_sre.Ghidra com.github.IsmaelMartinez.teams_for_linux com.prusa3d.PrusaSlicer org.libreoffice.LibreOffice org.gimp.GIMP org.winehq.Wine org.mamedev.MAME org.videolan.VLC org.gnome.Mines

onedrive:
	onedrive
	systemctl --user enable onedrive
	systemctl --user start onedrive

vbox:
	curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/vbox.gpg
	echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $$(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
	sudo apt update
	sudo apt install virtualbox-7.0

pwsh:
	wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
	sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb
	rm powershell_7.4.0-1.deb_amd64.deb

firmware:
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

size:
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

