help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | column -tl 2

install: ## install base system - idempotent
	sudo cp -R $(CURDIR)/etc/apt /etc
	sudo apt update -q
	sudo apt autoremove --purge -y -q
	sudo apt upgrade -y -q
	sudo apt install -y -q atril build-essential chromium cifs-utils cm-super cups curl docker-compose firefox-esr flatpak fwupd fzf gdb-multiarch htop libreoffice-calc libreoffice-impress libreoffice-writer libpam-fprintd libx11-dev libxft-dev libxinerama-dev lightdm ltrace meld ncat network-manager-gnome network-manager-openvpn-gnome nmap onedrive openscad powershell python3-venv python3-pwntools python3-pycryptodome python3-z3 ristretto snapd socat speedcrunch strace suckless-tools texlive-lang-german texlive-science thunar-archive-plugin tldr tlslookup tshark vim-gtk3 virtualbox-7.0 virt-viewer wireshark xfce4 xfce4-clipman-plugin xfce4-power-manager xfce4-screenshooter xfce4-terminal xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev zoxide
	sudo apt clean -q
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install --noninteractive flathub com.prusa3d.PrusaSlicer org.ghidra_sre.Ghidra

init: ## init software - idempotent
	sudo usermod -aG adm,dialout,docker,lp,lpadmin,staff,systemd-journal,vboxusers,wireshark $(USER)
	ln -sf $(CURDIR)/home/user/gitconfig $(HOME)/.gitconfig
	ln -sf $(CURDIR)/home/user/vimrc $(HOME)/.vimrc
	ln -sf $(CURDIR)/home/user/xsessionrc $(HOME)/.xsessionrc
	sudo ln -sf $(CURDIR)/usr/local/bin/mon /usr/local/bin
	grep -q zoxide $(HOME)/.bashrc || echo 'eval "$$(zoxide init bash)"' >> $(HOME)/.bashrc
	systemctl is-active --quiet --user onedrive || (onedrive && systemctl --user --now enable onedrive)
	if fprintd-list $(USER) | grep -iq "no fingers enrolled"; then fprintd-enroll; fi
	sudo pam-auth-update --enable fprintd

firmware: ## upgrade firmware
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

printer: ## configure cups
	xdg-open http://localhost:631/admin

.PHONY: help install init firmware printer
