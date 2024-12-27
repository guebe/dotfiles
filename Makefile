help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | column -tl 2

install: ## install base system
	sudo cp -R $(CURDIR)/etc/apt /etc
	sudo apt update -q
	sudo apt autoremove --purge -y -q
	sudo apt upgrade -y -q
	sudo apt install -y -q atril build-essential chromium cifs-utils cm-super cups curl docker-compose firefox-esr flatpak forticlient fwupd fzf gdb-multiarch htop libreoffice-calc libreoffice-impress libreoffice-writer libpam-fprintd lightdm ltrace meld ncat network-manager-gnome network-manager-openvpn-gnome nmap onedrive openscad powershell python3-venv python3-pwntools python3-pycryptodome python3-z3 ristretto snapd socat speedcrunch strace suckless-tools texlive-lang-german texlive-science thunar-archive-plugin tldr tlslookup tshark vim-gtk3 virtualbox-7.1 virt-viewer wireshark xfce4 xfce4-clipman-plugin xfce4-power-manager xfce4-screenshooter xfce4-terminal xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-video-fbdev zoxide
	sudo apt clean -q
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install --noninteractive flathub com.prusa3d.PrusaSlicer org.ghidra_sre.Ghidra

init: ## init software
	@sudo usermod -aG docker,lpadmin,vboxusers,wireshark $(USER)
	@if fprintd-list $(USER) | grep -qF "no fingers enrolled"; then fprintd-enroll; fi
	@sudo pam-auth-update --enable fprintd
	@sudo ln -sf $(CURDIR)/usr/local/bin/mon /usr/local/bin
	@ln -sf $(CURDIR)/home/user/gitconfig $(HOME)/.gitconfig
	@ln -sf $(CURDIR)/home/user/tmux.conf $(HOME)/.tmux.conf
	@ln -sf $(CURDIR)/home/user/vimrc $(HOME)/.vimrc
	@ln -sf $(CURDIR)/home/user/xsessionrc $(HOME)/.xsessionrc
	@systemctl is-active --quiet --user onedrive || (onedrive && systemctl --user --now enable onedrive)
	@grep -qF "zoxide init bash" $(HOME)/.bashrc || echo 'eval "$$(zoxide init bash)"' >> $(HOME)/.bashrc
	@grep -qF "/var/lib/flatpak/exports/bin" $(HOME)/.profile || echo 'export PATH="$$PATH:/var/lib/flatpak/exports/bin"' >> $(HOME)/.profile
	@nmcli connection show gandalf >/dev/null 2>/dev/null || nmcli connection add type wifi con-name gandalf ifname wlp0s20f3 ssid gandalf wifi-sec.key-mgmt wpa-psk
	@nmcli connection show radagast >/dev/null 2>/dev/null || nmcli connection add type wifi con-name radagast ifname wlp0s20f3 ssid radagast wifi-sec.key-mgmt wpa-psk
	@nmcli connection show htlhl >/dev/null 2>/dev/null || nmcli connection add type wifi con-name htlhl ifname wlp0s20f3 ssid HTLHL wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity changeme 802-1x.phase2-auth mschapv2
	@lpstat -v epson >/dev/null 2>/dev/null || /usr/sbin/lpadmin -p epson -E -v ipp://10.0.0.4/ipp/print -m everywhere -o media-default=A4 -o printer-is-shared=false
	@lpstat -v htlhl >/dev/null 2>/dev/null || /usr/sbin/lpadmin -p follow_you -E -v smb://print.htl-hl.ac.at/FollowYou -m drv:///sample.drv/generic.ppd -o media=A4 -o printer-is-shared=false

firmware: ## upgrade firmware
	@sudo fwupdmgr refresh --force
	@sudo fwupdmgr update

.PHONY: help install init firmware
