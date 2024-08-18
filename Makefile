GROUPS:=dialout docker vboxusers wireshark

DOTFILES:=gitconfig vimrc xsessionrc

PKGS:=atril bash-completion build-essential cowsay cups dkms dnsutils docker-compose docker.io file firefox-esr flatpak fwupd fzf gdb git gnupg2 htop hunspell libx11-dev libxft-dev libxinerama-dev lightdm mame meld mousepad ncat network-manager-gnome network-manager-openvpn-gnome nmap onedrive openscad pkgconf powershell pv python3-venv ristretto sl snapd speedcrunch thunar-archive-plugin tldr vim virtualbox-7.0 wine wget wireshark xfce4 xfce4-clipman-plugin xfce4-power-manager xfce4-screenshooter xfce4-terminal xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev zoxide z80asm z80dasm

APPS:=org.chromium.Chromium com.prusa3d.PrusaSlicer org.ghidra_sre.Ghidra org.gimp.GIMP org.libreoffice.LibreOffice org.videolan.VLC us.zoom.Zoom

help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | column -tl 2

install: ## install base system - idempotent
	sudo cp -R apt /etc
	sudo apt-get -qq update
	sudo apt-get -qq --auto-remove install $(PKGS)
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install --noninteractive flathub $(APPS)

init: ## init software - idempotent
	for FILE in $(DOTFILES); do \
		ln -sf $(CURDIR)/$$FILE $(HOME)/.$$FILE; \
	done
	for GROUP in $(GROUPS); do \
		sudo usermod -aG $$GROUP $(USER); \
	done
	sudo update-alternatives --set editor /usr/bin/vim.basic
	grep -q zoxide $(HOME)/.bashrc || echo 'eval "$$(zoxide init bash)"' >> $(HOME)/.bashrc
	systemctl is-active --quiet --user onedrive || (onedrive && systemctl --user --now enable onedrive)

firmware: ## upgrade firmware
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

printer: ## configure cups
	xdg-open http://localhost:631/admin

size: ## sort installed packets by size
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

.PHONY: help install init firmware printer size
