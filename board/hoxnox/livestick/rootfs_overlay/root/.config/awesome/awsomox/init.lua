-- @author Merder Kim <hoxnox@gmail.com>
-- @date 20170308
-- @license Apache 2.0

ArcLoad = require("awsomox.arcload")
Battery = require("awsomox.battery")
Memory = require("awsomox.memory")
Filesystem = require("awsomox.filesystem")


return {
    arcload = function(height, width, timeout)
        return ArcLoad.new(height, width, timeout)
    end,
    battery = function(height, width, timeout)
        return Battery.new(height, width, timeout)
    end,
    memory = function(height, width, timeout)
        return Memory.new(height, width, timeout)
    end,
    filesystem = function(height, width, timeout)
        return Filesystem.new(height, width, timeout)
    end
}

