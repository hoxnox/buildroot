#!/bin/sh

if [ -f "$1/etc/init.d/S40xorg" ]; then
    rm "$1/etc/init.d/S40xorg"
fi

chmod g-rwx,o-rwx -R "$1/root/.ssh"
chmod +x "$1/root/.mount-win"
