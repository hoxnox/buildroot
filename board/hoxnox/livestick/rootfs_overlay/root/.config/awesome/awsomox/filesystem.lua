-- @author Merder Kim <hoxnox@gmail.com>
-- @date 20170329
-- @license Apache 2.0 
-- note: Awesome 4.1 required

local io = { open  = io.open, popen = io.popen }
local wibox = require("wibox")
local gears = require("gears")

local Filesystem = {}
Filesystem.__index = Filesystem

function dbg(v)
  local f = io.open("/tmp/lua_debug.txt", "a")
  f:write(v)
  f:write('\n')
  f:close()
end

function Filesystem.new(name, height, width, timeout)
  local self = setmetatable({}, Filesystem)
  height = height or 45
  width = width or 45
  self.name = name or '/'

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

  self.timeout = timeout or 60
  self.timer = gears.timer.start_new(self.timeout, function() return self:step() end)
  self.timer:emit_signal("timeout")
  return self.widget
end

function fs_now(name)
    local f = io.popen("df "..name)
    _ = f:read()
    local nums = string.gmatch(f:read(), '%S+')
    _ = nums()
    local total = nums()
    local used = nums()
    return used/total
end

function Filesystem:set_val(val)
    if val > 1 then
        self.widget.value = 1
    elseif val < 0 then
        self.widget.value = 0
    else
        self.widget.value = val
    end

    if val > 0.9 then
        self.widget.color = '#ff7d76'
        self.textbox:set_markup('<span foreground="#ff7d76">✇</span>')
    elseif val > 0.8 then
        self.widget.color = '#ffdfa2'
        self.textbox:set_markup('<span foreground="#ffdfa2">✇</span>')
    else
        self.widget.color = theme.fg_normal
        self.textbox:set_markup('<span foreground="'..theme.fg_normal..'">✇</span>')
    end
end

function Filesystem:step()
    self:set_val(fs_now(self.name))
    self.timer.timeout = self.timeout
    self.timer:again()
    return true
end

return Filesystem

