-- @author Merder Kim <hoxnox@gmail.com>
-- @date 20170329
-- @license Apache 2.0 
-- note: Awesome 4.1 required

local io = { open  = io.open, popen = io.popen }
local wibox = require("wibox")
local gears = require("gears")

local Battery = {}
Battery.__index = Battery

function dbg(v)
  local f = io.open("/tmp/lua_debug.txt", "a")
  f:write(v)
  f:write('\n')
  f:close()
end

function Battery.new(height, width, timeout)
  local self = setmetatable({}, Battery)
  height = height or 45
  width = width or 45

  self.textbox = wibox.widget.textbox()
  self.text_place = wibox.container.place(self.textbox)
  self.text_place.widget = self.textbox

  self.widget = wibox.container.radialprogressbar(self.text_place)
  self.widget.widget = self.text_place
  self.widget.min_value = 0
  self.widget.max_value = 1
  self.widget.paddings = width/10
  self.widget.border_width = width/10
  self.widget.value = 0
  self.widget.color = theme.fg_normal
  self.widget.border_color = theme.bg_normal
  self.widget.forced_height = height
  self.widget.forced_width = width

  self.timeout = timeout or 1
  self.timer = gears.timer.start_new(self.timeout, function() return self:step() end)
  self.timer:emit_signal("timeout")
  return self.widget
end

function bat_now()
    local f = io.open("/sys/class/power_supply/BAT0/charge_full")
    local charge_full = tonumber(f:read("*all"))
    f:close()
    local f = io.open("/sys/class/power_supply/BAT0/charge_now")
    local charge_now = tonumber(f:read("*all"))
    f:close()
    return charge_now/charge_full
end

function power_status()
    local f = io.open("/sys/class/power_supply/BAT0/status")
    local status = f:read("*all")
    f:close()
    if status == 'Discharging\n' then
        return '⚛' -- there should be U+1F50B
    elseif status == 'Charging\n' then
        return '⚡' -- maybe something interesting here
    end
    return '⚡'
end

function Battery:set_val(val)
    if val > 1 then
        self.widget.value = 1
    elseif val < 0 then
        self.widget.value = 0
    else
        self.widget.value = val
    end

    if val < 0.15 and status == 'Discharging\n' then
        self.widget.color = '#ff7d76'
        self.textbox:set_markup('<span foreground="#ff7d76">⚠</span>')
    elseif val < 0.3 then
        self.widget.color = '#ffdfa2'
        self.textbox:set_markup('<span foreground="#ffdfa2">'..power_status()..'</span>')
    else
        self.widget.color = theme.fg_normal
        self.textbox:set_markup('<span foreground="'..theme.fg_normal..'">'..power_status()..'</span>')
    end
end

function Battery:step()
    self:set_val(bat_now())
    self.timer.timeout = self.timeout
    self.timer:again()
    return true
end

return Battery

