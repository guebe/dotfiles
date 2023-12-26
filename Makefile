.PHONY: help
help:
	@echo "install   ... apt install packets"
	@echo "git       ... configure git"
	@echo "vim       ... install vim"
	@echo "zoxide    ... install zoxide"
	@echo "wireshark ... install wireshark"
	@echo "flatpak   ... install flatpak"
	@echo "onedrive  ... install onedrive"
	@echo "vbox      ... install virtualbox"
	@echo "pwsh      ... install powershell"
	@echo "firmware  ... upgrade firmware"
	@echo "size      ... sort installed packets by size"

.PHONY: install
install:
	sudo apt update
	sudo apt install xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev lightdm xfce4 xfce4-terminal network-manager-gnome build-essential gdb atril ristretto xfce4-clipman-plugin xfce4-screenshooter xfce4-power-manager tldr bash-completion firefox-esr openscad speedcrunch
	test -e ${HOME}/.xsessionrc || ln -s ${PWD}/xsessionrc ${HOME}/.xsessionrc

.PHONY: git
git:
	sudo apt install git
	git config --global credential.helper store
	git config --global user.name "gue"
	git config --global user.email gue@debian.home

.PHONY: vim
vim:
	sudo apt install vim
	sudo update-alternatives --set editor /usr/bin/vim.basic
	test -e ${HOME}/.vimrc || ln -s ${PWD}/vimrc ${HOME}/.vimrc

.PHONY: zoxide
zoxide:
	sudo apt install zoxide fzf
	grep -q zoxide ${HOME}/.bashrc || zoxide init bash >> ${HOME}/.bashrc

.PHONY: wireshark
wireshark:
	sudo apt install wireshark
	sudo usermod -aG wireshark ${USER}

.PHONY: flatpak
flatpak:
	sudo apt install flatpak
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub us.zoom.Zoom org.ghidra_sre.Ghidra com.github.IsmaelMartinez.teams_for_linux com.prusa3d.PrusaSlicer org.libreoffice.LibreOffice org.gimp.GIMP org.winehq.Wine org.mamedev.MAME org.videolan.VLC org.gnome.Mines org.gnome.meld

.PHONY: onedrive
onedrive:
	sudo apt install onedrive
	onedrive
	systemctl --user enable onedrive
	systemctl --user start onedrive

.PHONY: vbox
vbox:
	sudo apt update
	sudo apt install curl gnupg2 lsb-release dkms
	curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/vbox.gpg
	echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $$(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
	sudo apt update
	sudo apt install virtualbox-7.0
	sudo usermod -aG vboxusers ${USER}

.PHONY: pwsh
pwsh:
	sudo apt install wget
	wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
	sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb
	sudo apt-get install -f
	rm powershell_7.4.0-1.deb_amd64.deb

.PHONY: firmware
firmware:
	sudo apt install fwupd
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

.PHONY: size
size:
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

