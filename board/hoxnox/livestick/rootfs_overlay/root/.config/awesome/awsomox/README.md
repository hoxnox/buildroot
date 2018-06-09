# Awesome window manager widgets

Awesome 4.1 required!

- arcload - arc widget shows system loadavg
- battery - arc widget shows battery status
- memory - arc widget shows memory usage
- filesystem - arc widget shows filesystem usage

![battery](https://habrastorage.org/files/0d0/4e7/0b7/0d04e70b7f3d41dc8639dc60e26bd2c5.png)

Installing:

    cd ~/.config/awesome
    git clone https://github.com/hoxnox/awsomox.git

usage in rc.lua:

    awsomox = require("awsomox")

    arccpu = awsomox.arcload()
    battery = awsomox.battery()
    memory = awsomox.memory()
    filesystem = awsomox.filesystem('/home')

    -- if defaults too big
    arccpu32 = awsomox.arcload(32, 32, 1) -- 32pt sized

