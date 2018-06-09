#!/bin/sh

if [ -f "$1/etc/init.d/S40xorg" ]; then
    rm "$1/etc/init.d/S40xorg"
fi
