DOTFILES := xsessionrc vimrc gitconfig

PKGS := xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev lightdm xfce4 thunar-archive-plugin xfce4-terminal network-manager-gnome build-essential gdb atril ristretto xfce4-clipman-plugin xfce4-screenshooter xfce4-power-manager tldr bash-completion firefox-esr openscad speedcrunch libx11-dev libxft-dev pkgconf libxinerama-dev dnsutils python3-venv meld git vim zoxide fzf wireshark flatpak onedrive gnupg2 dkms wget fwupd virtualbox-7.0 powershell file

APPS := us.zoom.Zoom org.ghidra_sre.Ghidra com.github.IsmaelMartinez.teams_for_linux com.prusa3d.PrusaSlicer org.libreoffice.LibreOffice org.gimp.GIMP org.winehq.Wine//stable-23.08 org.mamedev.MAME org.videolan.VLC org.gnome.Mines

help:
	@echo 'install     ... install base system - idempotent'
	@echo 'init        ... init software - idempotent'
	@echo 'firmware    ... upgrade firmware'
	@echo 'size        ... sort installed packets by size'

install:
	sudo cp -R apt /etc
	sudo apt-get -qq update
	sudo apt-get -qq autoremove
	sudo apt-get -qq install $(PKGS)
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install --noninteractive flathub $(APPS)

init:
	for FILE in $(DOTFILES); do \
		ln -sf $(CURDIR)/$$FILE $(HOME)/.$$FILE; \
	done
	sudo usermod -aG dialout,vboxusers,wireshark $(USER)
	sudo update-alternatives --set editor /usr/bin/vim.basic
	grep -q zoxide $(HOME)/.bashrc || echo 'eval "$$(zoxide init bash)"' >> $(HOME)/.bashrc
	systemctl is-active --quiet --user onedrive || (onedrive && systemctl --user --now enable onedrive)

firmware:
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

size:
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

.PHONY: help install init firmware size
