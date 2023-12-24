.PHONY: help
help:
	@echo "links     ... install symlinks for config files"
	@echo "install   ... apt install packets"
	@echo "vim       ... install vim"
	@echo "wireshark ... install wireshark"
	@echo "onedrive  ... install onedrive"
	@echo "vbox      ... install virtualbox"
	@echo "git       ... configure git"
	@echo "pwsh      ... install powershell"
	@echo "flatpak   ... install flatpak"
	@echo "firmware  ... upgrade firmware"
	@echo "size      ... sort installed packets by size"

.PHONY: links
links:
	ln -is ${PWD}/tmux.conf ${HOME}/.tmux.conf
	ln -is ${PWD}/xsessionrc ${HOME}/.xsessionrc

.PHONY: install
install:
	sudo apt update
	sudo apt install xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev lightdm xfce4 xfce4-terminal network-manager-gnome firefox-esr bash-completion build-essential fwupd gdb atril ristretto xfce4-clipman-plugin xfce4-screenshooter xfce4-power-manager meld openscad gnome-mines speedcrunch vlc gimp mame wine libreoffice-calc libreoffice-impress libreoffice-writer zoxide fzf tldr wget curl gnupg2 lsb-release dkms

.PHONY: vim
vim:
	sudo apt install vim
	sudo update-alternatives --set editor /usr/bin/vim.basic
	ln -is ${PWD}/vimrc ${HOME}/.vimrc

.PHONY: wireshark
wireshark:
	sudo apt install wireshark
	sudo usermod -aG wireshark ${USER}

.PHONY: onedrive
onedrive:
	sudo apt install onedrive
	onedrive
	systemctl --user enable onedrive
	systemctl --user start onedrive

.PHONY: vbox
vbox:
	curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/vbox.gpg
	curl -fsSL https://www.virtualbox.org/download/oracle_vbox.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/oracle_vbox.gpg
	echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $$(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
	sudo apt update
	sudo apt install virtualbox-7.0
	sudo usermod -aG vboxusers ${USER}

.PHONY: git
git:
	sudo apt install git
	git config --global credential.helper store
	git config --global --edit

.PHONY: pwsh
pwsh:
	wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
	sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb
	sudo apt-get install -f
	rm powershell_7.4.0-1.deb_amd64.deb

.PHONY: flatpak
flatpak:
	sudo apt install flatpak
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub us.zoom.Zoom org.ghidra_sre.Ghidra com.github.IsmaelMartinez.teams_for_linux com.prusa3d.PrusaSlicer

.PHONY: firmware
firmware:
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

.PHONY: size
size:
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

