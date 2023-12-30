DOTFILES := ${HOME}/.xsessionrc ${HOME}/.vimrc ${HOME}/.gitconfig

PKGS := xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev lightdm xfce4 thunar-archive-plugin xfce4-terminal network-manager-gnome build-essential gdb atril ristretto xfce4-clipman-plugin xfce4-screenshooter xfce4-power-manager tldr bash-completion firefox-esr openscad speedcrunch libx11-dev libxft-dev pkgconf libxinerama-dev dnsutils python3-venv meld git vim zoxide fzf wireshark flatpak onedrive gnupg2 dkms wget fwupd virtualbox-7.0 powershell file

APPS := us.zoom.Zoom org.ghidra_sre.Ghidra com.github.IsmaelMartinez.teams_for_linux com.prusa3d.PrusaSlicer org.libreoffice.LibreOffice org.gimp.GIMP org.winehq.Wine//stable-23.08 org.mamedev.MAME org.videolan.VLC org.gnome.Mines

help:
	@echo "install     ... install base system - idempotent"
	@echo "init        ... init software - idempotent"
	@echo "firmware    ... upgrade firmware"
	@echo "size        ... sort installed packets by size"

install: keyrings sources
	sudo apt-get -qq update
	sudo apt-get -qq autoremove
	sudo apt-get -qq install $(PKGS)
	@flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	@flatpak install --noninteractive flathub $(APPS)

init: $(DOTFILES)
	sudo usermod -aG dialout,vboxusers,wireshark ${USER}
	sudo update-alternatives --quiet --set editor /usr/bin/vim.basic
	grep -Fq zoxide ${HOME}/.bashrc || echo 'eval "$$(zoxide init bash)"' >> ${HOME}/.bashrc
	systemctl is-active --quiet --user onedrive || (onedrive && systemctl --user --now enable onedrive)

keyrings: /etc/apt/keyrings/virtualbox.gpg /etc/apt/keyrings/microsoft.gpg /etc/apt/keyrings/onedrive.gpg
sources: /etc/apt/sources.list.d/virtualbox.list /etc/apt/sources.list.d/microsoft.list /etc/apt/sources.list.d/onedrive.list

/etc/apt/keyrings/virtualbox.gpg: /usr/bin/curl
	curl -fsS https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor | sudo tee $@ >/dev/null

/etc/apt/sources.list.d/virtualbox.list:
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/virtualbox.gpg] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | sudo tee $@ >/dev/null

/etc/apt/keyrings/microsoft.gpg: /usr/bin/curl
	curl -fsS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee $@ >/dev/null

/etc/apt/sources.list.d/microsoft.list:
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] http://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" | sudo tee $@ >/dev/null

/etc/apt/keyrings/onedrive.gpg: /usr/bin/curl
	curl -fsS https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/Debian_12/Release.key | gpg --dearmor | sudo tee $@ >/dev/null

/etc/apt/sources.list.d/onedrive.list:
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/Debian_12/ ./" | sudo tee $@ >/dev/null

/usr/bin/curl:
	sudo apt-get -qq install curl

$(DOTFILES):
	@ln -sv $(PWD)/$(subst .,,$(@F)) $@

firmware:
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

size:
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

.PHONY: help install init firmware size
