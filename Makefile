DOTFILES:=gitconfig vimrc xsessionrc

PKGS:=atril bash-completion build-essential dkms dnsutils file firefox-esr flatpak fwupd fzf gdb git gnupg2 libx11-dev libxft-dev libxinerama-dev lightdm meld network-manager-gnome onedrive openscad pkgconf powershell python3-venv ristretto speedcrunch thunar-archive-plugin tldr vim virtualbox-7.0 wget wireshark xfce4 xfce4-clipman-plugin xfce4-power-manager xfce4-screenshooter xfce4-terminal xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev zoxide

APPS:=com.github.IsmaelMartinez.teams_for_linux com.prusa3d.PrusaSlicer org.ghidra_sre.Ghidra org.gimp.GIMP org.gnome.Mines org.libreoffice.LibreOffice org.mamedev.MAME org.videolan.VLC org.winehq.Wine//stable-23.08 us.zoom.Zoom

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
