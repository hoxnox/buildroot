-- @author Merder Kim <hoxnox@gmail.com>
-- @date 20170308
-- @license Apache 2.0 

local io = { open  = io.open, popen = io.popen }
local wibox = require("wibox")
local gears = require("gears")

local ArcLoad = {}
ArcLoad.__index = ArcLoad

function dbg(v)
  local f = io.open("/home/hoxnox/lua_debug.txt", "a")
  f:write(v)
  f:close()
end

function cpu_count()
    local f = io.popen("awk '$1==\"siblings\"{s=$3}END{print s}' /proc/cpuinfo")
    local cpu_cnt = tonumber(f:read("*all"))
    f:close()
    return cpu_cnt
end

function ArcLoad.new(height, width, timeout)
  height = height or 45
  width = width or 45
  local self = setmetatable({}, ArcLoad)
  self.charts = {}
  self.timeout = timeout or 1
  self.cpu_count = cpu_count()
  for i = 0,2 do
    if i == 0 then
        self.charts[i] = wibox.container.radialprogressbar()
    else
        self.charts[i] = wibox.container.radialprogressbar(self.charts[i-1])
        self.charts[i].widget = self.charts[i-1]
    end
    self.charts[i].min_value = 0
    self.charts[i].max_value = self.cpu_count
    self.charts[i].paddings = width/10
    self.charts[i].border_width = width/10
    self.charts[i].value = 0
    self.charts[i].color = theme.fg_normal
    self.charts[i].border_color = theme.bg_normal
  end
  self.charts[2].forced_height = height
  self.charts[2].forced_width = width
  self.timer = gears.timer.start_new(self.timeout, function() return self:step() end)
  self.timer:emit_signal("timeout")
  return self.charts[2]
end

function ArcLoad:set_val(idx, val)
    if val > self.cpu_count then
        self.charts[idx].value = self.cpu_count
    else
        self.charts[idx].value = val
    end
    if val > self.cpu_count*0.75 then
        self.charts[idx].color = "#ff7d76"
    elseif val > self.cpu_count*0.5 then
        self.charts[idx].color = "#ffdfa2"
    else
        self.charts[idx].color = theme.fg_normal
    end
end

function ArcLoad:step()
    local f = io.open("/proc/loadavg")
    local loadavg = f:read("*all")
    f:close()

    load_1, load_5 ,load_15 = string.match(loadavg, "([0-9.]+) ([0-9.]+) ([0-9.]+)")

    self:set_val(2, tonumber(load_1))
    self:set_val(1, tonumber(load_5))
    self:set_val(0, tonumber(load_15))

    self.timer.timeout = self.timeout
    self.timer:again()
    return true
end

return ArcLoad

