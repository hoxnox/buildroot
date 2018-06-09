#!/bin/sh

export SHELL=/bin/zsh
ifconfig -a  | grep -q E0:69:95:36:C0:E1 \
	&& ifconfig eth0 128.4.1.82 netmask 255.255.0.0 && route add -net 128.44.44.0 netmask 255.255.252.0 gw 128.4.1.1 \
	&& cp ~/.config/awesome/rc.custom.lua ~/.config/awesome/rc.lua
SSH_ASKPASS=ssh-askpass-fulscreen LANG=ru_RU.UTF-8 LC_ALL=ru_RU.UTF-8 exec ssh-agent awesome
