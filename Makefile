GROUPS:=dialout docker vboxusers wireshark

DOTFILES:=gitconfig vimrc xsessionrc

PKGS:=atril bash-completion binwalk build-essential checksec cm-super cifs-utils cowsay csvtool cups dkms dnsutils docker-compose docker.io file firefox-esr flatpak fprintd fwupd fzf gdb gdb-multiarch git gnupg2 gnuradio htop hunspell indent inspectrum libpam-fprintd libx11-dev libxft-dev libxinerama-dev lightdm llvm ltrace mame meld minicom mousepad ncat network-manager-fortisslvpn-gnome network-manager-gnome network-manager-openvpn-gnome nmap onedrive openscad openssh-server pkgconf powershell pv python3-venv python3-pwntools python3-z3 ristretto sl snapd socat speedcrunch strace suckless-tools telnet testdisk texlive-lang-german texlive-science thunar-archive-plugin tldr tlslookup tshark vim-gtk3 virtualbox-7.0 virtualenvwrapper virt-viewer wine wget wireguard-tools wireshark xfce4 xfce4-clipman-plugin xfce4-power-manager xfce4-screenshooter xfce4-terminal xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev zoxide z80asm z80dasm

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
	sudo ln -sf $(CURDIR)/usr/local/bin/mon /usr/local/bin
	for GROUP in $(GROUPS); do \
		sudo usermod -aG $$GROUP $(USER); \
	done
	sudo update-alternatives --set editor /usr/bin/vim.basic
	grep -q zoxide $(HOME)/.bashrc || echo 'eval "$$(zoxide init bash)"' >> $(HOME)/.bashrc
	systemctl is-active --quiet --user onedrive || (onedrive && systemctl --user --now enable onedrive)

firmware: ## upgrade firmware
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

fingerprint: ## fingerprint reader
	fprintd-enroll
	sudo pam-auth-update

printer: ## configure cups
	xdg-open http://localhost:631/admin

size: ## sort installed packets by size
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

.PHONY: help install init firmware printer size
