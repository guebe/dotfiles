help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | column -tl 2

install: ## install packages
	sudo cp -R $(CURDIR)/etc/apt /etc
	sudo apt update -qq
	sudo apt install -qq build-essential cifs-utils cups curl docker-compose feh firefox-esr flatpak forticlient fwupd fzf gdb-multiarch git gitk gnome-shell htop libpam-fprintd libreoffice-calc libreoffice-gnome libreoffice-writer libxft-dev libx11-dev ltrace meld nautilus network-manager-openvpn-gnome nmap onedrive openscad pandoc powershell python3-pwntools python3-pycryptodome python3-venv python3-z3 qemu-system-x86 qemu-user smbclient socat strace texlive-latex-base texlive-latex-extra tldr tshark vim virtualbox-7.1 virt-viewer wireshark zoxide
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install --noninteractive flathub com.prusa3d.PrusaSlicer org.ghidra_sre.Ghidra

config: ## config software
	@sudo usermod -aG docker,lpadmin,vboxusers,wireshark $(USER)
	@sudo update-alternatives  --set editor /usr/bin/vim.basic
	@if fprintd-list $(USER) | grep -qF "no fingers enrolled"; then fprintd-enroll; fi
	@sudo pam-auth-update --enable fprintd
	@#@for file in $(CURDIR)/bin/*; do sudo ln -sf $$file /usr/local/bin; done
	@ln -sf $(CURDIR)/home/gitconfig $(HOME)/.gitconfig
	@ln -sf $(CURDIR)/home/vimrc $(HOME)/.vimrc
	@mkdir -p $(HOME)/.vim/colors
	@ln -sf $(CURDIR)/home/eldar.vim $(HOME)/.vim/colors
	@systemctl is-active --quiet --user onedrive || (onedrive && systemctl --user --now enable onedrive)
	@grep -qF "zoxide init bash" $(HOME)/.bashrc || echo 'eval "$$(zoxide init bash)"' >> $(HOME)/.bashrc
	@grep -qF "source /usr/share/doc/fzf/examples/key-bindings.bash" $(HOME)/.bashrc || echo "source /usr/share/doc/fzf/examples/key-bindings.bash" >> $(HOME)/.bashrc
	@#@grep -qF "/var/lib/flatpak/exports/bin" $(HOME)/.profile || echo 'export PATH="$$PATH:/var/lib/flatpak/exports/bin"' >> $(HOME)/.profile
	@nmcli connection show gandalf >/dev/null 2>/dev/null || nmcli connection add type wifi con-name gandalf ifname wlp0s20f3 ssid gandalf wifi-sec.key-mgmt wpa-psk
	@nmcli connection show radagast >/dev/null 2>/dev/null || nmcli connection add type wifi con-name radagast ifname wlp0s20f3 ssid radagast wifi-sec.key-mgmt wpa-psk
	@nmcli connection show htlhl >/dev/null 2>/dev/null || nmcli connection add type wifi con-name htlhl ifname wlp0s20f3 ssid HTLHL wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.ca-cert $(HOME)/ad_ca.cer 802-1x.identity changeme 802-1x.phase2-auth mschapv2
	@lpstat -v epson >/dev/null 2>/dev/null || /usr/sbin/lpadmin -p epson -E -v ipp://10.0.0.4/ipp/print -m everywhere -o printer-is-shared=false
	@lpoptions -p epson -o PageSize=A4
	@lpoptions -d epson > /dev/null
	@lpstat -v follow_you >/dev/null 2>/dev/null || /usr/sbin/lpadmin -p follow_you -E -v smb://print.htl-hl.ac.at/FollowYou -m drv:///sample.drv/generic.ppd -o media=A4 -o printer-is-shared=false

firmware: ## update firmware
	@sudo fwupdmgr refresh --force
	@sudo fwupdmgr update

.PHONY: help install config firmware
