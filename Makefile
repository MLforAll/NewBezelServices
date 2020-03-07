# Config
NAME := NewBezelServices.app
INSTALL_ROOT := /Library/Services
AGENT := com.mlforall.NewBezelServices.plist

# Auto
INSTALL_PATH := $(INSTALL_ROOT)/$(NAME)
AGENT_PATH := /Library/LaunchAgents/$(AGENT)
CONSOLE_USER := $(shell stat -f '%Su' /dev/console)

all: release

release:
	xcodebuild -configuration Release

debug:
	xcodebuild -configuration Debug

mustroot:
	@ [ `id -u` -eq 0 ] || { echo 'You must run this as root' >&2; exit 1; }

install: mustroot
	@ [ -d "$(INSTALL_ROOT)" ] || mkdir -p "$(INSTALL_ROOT)"
	su "$(CONSOLE_USER)" -c 'launchctl unload "$(AGENT_PATH)"'
	rm -rf "$(INSTALL_PATH)" "$(AGENT_PATH)"
	cp -R "build/Release/$(NAME)" "$(INSTALL_ROOT)"
	chown -R root:wheel "$(INSTALL_PATH)"
	cp "$(AGENT)" "$(AGENT_PATH)"
	chmod 0644 "$(AGENT_PATH)"
	chown root:wheel "$(AGENT_PATH)"
	su "$(CONSOLE_USER)" -c 'launchctl load "$(AGENT_PATH)"'

clean:
	rm -rf build
fclean: clean

re: clean all

.PHONY: release debug mustroot install clean fclean re
