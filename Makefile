.PHONY: help
help:
	@echo "all"
	@echo "  links   ... install symlinks for config files"
	@echo "  install ... apt install packets"
	@echo "  git     ... configure git"
	@echo "  pwsh    ... install powershell"
	@echo "firmware  ... upgrade firmware"
	@echo "size      ... sort installed packets by size"

.PHONY: all
all: links install git pwsh

.PHONY: links
links:
	ln -is ${PWD}/vimrc ${HOME}/.vimrc
	ln -is ${PWD}/tmux.conf ${HOME}/.tmux.conf
	ln -is ${PWD}/xsessionrc ${HOME}/.xsessionrc

.PHONY: install
install:
	sudo apt update
	sudo apt install bash-completion vim-gtk3 build-essential flatpak git fwupd
	sudo update-alternatives --set editor /usr/bin/vim.gtk3

.PHONY: git
git:
	git config credential.helper store
	git config --global --edit

.PHONY: pwsh
pwsh:
	wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
	sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb
	sudo apt-get install -f
	rm powershell_7.4.0-1.deb_amd64.deb

.PHONY: firmware
firmware:
	sudo fwupdmgr refresh --force
	sudo fwupdmgr update

.PHONY: size
size:
	dpkg-query -Wf '$${Installed-Size}\t$${Package}\n' | sort -n

