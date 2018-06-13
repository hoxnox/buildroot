-- custom
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
--local vicious.widgets.cpu = require("/home/hoxnox/.config/awesome/cpu.lua")
local hotkeys_popup = require("awful.hotkeys_popup").widget

awsomox = require("awsomox")

awful.util.spawn('xrandr --auto --output DVI-I-1 --rotate left --left-of HDMI-1')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

function dbg(message)
    naughty.notify({ preset = naughty.config.presets.normal,
                     title = "debug",
                     text = message })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/root/.config/awesome/themes/hoxnox.lua")


window_controlls_apps = {"Pavucontrol", "Skype", "Pidgin", "gimp", "keepassxc", "Deadbeef"}

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile.right,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 500 } })
        end
    end
end
-- }}}

-- This is used later as the default terminal and editor to run.
terminal = "ssh sun terminator"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor

-- {{{ Menu
-- Create a launcher widget and a main menu
mymainmenu = awful.menu({ items = {
                                   { "terminal", terminal },
                                   { "local terminal", "xterm" },
                                   { "awrestart", awesome.restart },
}})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mylswitcher = {}
mylswitcher.capture = {"us", "ru"}
mylswitcher.widget = wibox.widget.textbox()
mylswitcher.current = 1
mylswitcher.widget.forced_width = 35
mylswitcher.widget.align = "center"
mylswitcher.widget:set_markup(mylswitcher.capture[mylswitcher.current])
mylswitcher.switch = function()
    if mylswitcher.current == 1 then
        mylswitcher.current = 2
    else
        mylswitcher.current = 1
    end
    -- mylswitcher.current = mylswitcher.current % #(mylswitcher.layout) + 1
    local t = mylswitcher.capture[mylswitcher.current]
    mylswitcher.widget:set_markup(t)
    local fh = io.popen("xkb-switch -s " .. mylswitcher.capture[mylswitcher.current])
    io.close(fh)
end
-- Mouse bindings
mylswitcher.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () mylswitcher.switch() end)
))

wibox_widget_height = 20
wibox_widget_width  = 25

arcload = awsomox.arcload(wibox_widget_height, wibox_widget_width)
memory = awsomox.memory(wibox_widget_height, wibox_widget_width)

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%Y.%m.%d %H:%M:%S", 1)

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

tags = {}

local screen_left = 1
local screen_right = 2

-- Each screen has its own tag table.
tags[screen_left] = awful.tag({ 1, 2, 3, 4, 5 }, screen_left, awful.layout.suit.tile.top)
tags[screen_right] = awful.tag({ 6, 7, 8, 9 }, screen_right, awful.layout.suit.tile.right)
awful.tag.setproperty(tags[screen_left][1], "master_width_factor", 0.75)
awful.tag.setproperty(tags[screen_left][2], "master_width_factor", 0.75)
awful.tag.setproperty(tags[screen_left][3], "master_width_factor", 0.75)
awful.tag.setproperty(tags[screen_left][4], "master_width_factor", 0.75)
awful.tag.setproperty(tags[screen_left][5], "master_width_factor", 0.75)

awful.tag.setproperty(tags[screen_right][1], "master_width_factor", 0.50)
awful.tag.setproperty(tags[screen_right][2], "master_width_factor", 0.50)
awful.tag.setproperty(tags[screen_right][3], "master_width_factor", 0.50)
awful.tag.setproperty(tags[screen_right][4], "master_width_factor", 0.50)
-- }}}

--
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )

separator = wibox.widget.textbox()
separator:set_markup('<span color="#333333">|</span>')

for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt()
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(separator)
    right_layout:add(arcload)
    right_layout:add(memory)
    right_layout:add(separator)
    right_layout:add(mylswitcher.widget)
    right_layout:add(separator)
    right_layout:add(mytextclock)
    right_layout:add(wibox.widget.systray())

    -- now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen.index]:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = mypromptbox[mouse.screen.index].widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

function get_gkrellm()
	local clients = client.get()
	local gkrellm = nil
	local i = 1
	local gkrellm
	for _,c in ipairs(client.get())
		do
			if c.class == "Gkrellm" then
				return c
			end
		end
		return nil
end

function gkrellm_show(c)
	gkrellm = get_gkrellm()
	if gkrellm then
		gkrellm.ontop = true;
		gkrellm.above = true;
	end
end

function gkrellm_hide(c)
	gkrellm = get_gkrellm()
	if gkrellm then
		gkrellm.ontop = false;
		gkrellm.below = true;
	end
end

globalkeys = awful.util.table.join(globalkeys,
awful.key({},"F12", gkrellm_show, gkrellm_hide),
--awful.key({"Mod1"}, "#65", nil, function() switch_key_layout_vimspecial() end),

--awful.key({"Control",}, "Shift_L", function () mylswitcher.switch() end),
--awful.key({"Mod1",}, "space", function () mylswitcher.switch() end),
awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer sset Master 2+") end),
awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer sset Master 2-") end),
awful.key({}, "XF86AudioMute", function () awful.util.spawn("amixer sset Master toggle") end))

for i = 1, 5 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                            awful.tag.viewonly(tags[screen_left][i])
                            awful.screen.focus(screen_left)
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                          awful.tag.viewtoggle(tags[screen_left][i])
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                          awful.client.movetotag(tags[screen_left][i])
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                          awful.client.toggletag(tags[screen_left][i])
                  end))
end

for i = 6, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                            awful.tag.viewonly(tags[screen_right][i - 5])
                            awful.screen.focus(screen_right)
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                          awful.tag.viewtoggle(tags[screen_right][i - 5])
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                          c = client.focus
                          --c.screen = screen_right;
                          awful.client.movetotag(tags[screen_right][i - 5])
                          --awful.client.restore(c)
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                          awful.client.toggletag(tags[screen_right][i - 5])
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false},
      callback = awful.client.setslave },
    { rule_any = { class = opacityapps },
      properties = { opacity = 0.85 } },
    { rule_any = { class = floatingapps },
      properties = { floating = true } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][9]} },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][9]} },
    { rule = { class = "Exe" },
      properties = { fullscreen = true } },
    { rule = { class = "Skype" },
      properties = { tag = tags[1][9] } },
    { rule = { class = "Gkrellm" },
      properties = {
          opacity = 0.85
         ,floating = true
      },
      callback = function(c)
          padding_x = 5
          padding_y = 5
          screen_width = 1200
          screen_height = 1600
          curr_geometry = c:geometry()
          c:geometry({x = screen_width - curr_geometry.width - padding_x,
                      y = screen_height - curr_geometry.height - padding_y})
      end
    },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    if not awesome.startup and c.class ~= "Gkrellm" then
    	awful.client.movetoscreen(c, mouse.screen.index)
	awful.client.setmaster(c)
        client.focus = c
	c:raise()
        --awful.mouse.client.resize(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            --awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            --awful.titlebar.widget.stickybutton   (c),
            --awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- ===========================================================================
-- =                 C U S T O M                                             =
-- ===========================================================================

-- {{{ autorun

-- awful.util.spawn_with_shell("feh --bg-fill /root/pictures/wallpappers/look.jpg")
-- awful.util.spawn_with_shell("sudo tee /sys/class/backlight/intel_backlight/brightness <<< 600")
-- awful.util.spawn("xmodmap /root/.xmodmap") -- bind CapsLock to Esc
-- awful.util.spawn_with_shell("if [[ `ps -A | grep xcompmgr | awk '$4 ~ /xcompmgr/ {print 1}'` != 1 ]]; then xcompmgr -cF &>/dev/null & fi")
-- awful.util.spawn_with_shell("/home/hoxnox/.config/.scripts/unlock")
-- awful.util.spawn_with_shell("redshift")
-- awful.util.spawn("telegram-desktop -startintray")

-- }}}

-- {{{ tmux keys

function is_tmux(c)
    if string.find(string.lower(c.name), "tmux") ~= nil
    or string.find(string.lower(c.class), "tmux") ~= nil
    then
         return true
    end
    return false
end

function send_tmux_command(cmd)
    keygrabber.stop()
    root.fake_input("key_release", 64)
    root.fake_input("key_press", 64)
    root.fake_input("key_press", 38)
    root.fake_input("key_release", 38)
    root.fake_input("key_release", 64)
    waiter = timer({timeout = 0.01})
    if cmd == 'up' then
        waiter:connect_signal('timeout', function()
            waiter:stop()
            root.fake_input("key_press", 116)
            root.fake_input("key_release", 116)
            root.fake_input("key_press", 64)
        end)
    end
    if cmd == 'down' then
        waiter:connect_signal('timeout', function()
            waiter:stop()
            root.fake_input("key_press", 111)
            root.fake_input("key_release", 111)
            root.fake_input("key_press", 64)
        end)
    end
    waiter:start()
end

globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey,           }, "j",
        function()
            if is_tmux(client.focus) then
                send_tmux_command('down')
            else
                awful.client.focus.byidx(1)
                if client.focus then client.focus:raise() end
            end
        end),
    awful.key({ modkey,           }, "k",
        function()
            if is_tmux(client.focus) then
                send_tmux_command('up')
            else
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end
        end)
)

-- }}}

-- {{{ XF86 keys

globalkeys = awful.util.table.join(globalkeys,
    awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer sset Master 2+") end),
    awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer sset Master 2-") end),
    awful.key({}, "XF86AudioMute", function () awful.util.spawn("amixer sset Master toggle") end),
    awful.key({}, "XF86MonBrightnessUp", function () awful.util.spawn_with_shell("awk '{if($1+10>=1500) print 1500; else print $1+100;}' /sys/class/backlight/intel_backlight/brightness | sudo tee /sys/class/backlight/intel_backlight/brightness") end),
    awful.key({}, "XF86MonBrightnessDown", function () awful.util.spawn_with_shell("awk '{if($1-100<=0) print 100; else print $1-100;}' /sys/class/backlight/intel_backlight/brightness | sudo tee /sys/class/backlight/intel_backlight/brightness") end)
)

-- }}}

-- {{{ kyboard layout keys

function is_vim(c)
    if c and (string.find(string.lower(c.name), "vim") ~= nil
    or string.find(string.lower(c.class), "vim") ~= nil)
    then
        return true;
    end
    return false
end

function switch_key_layout_vimspecial()
    if is_vim(client.focus) then
        keygrabber.stop()
        -- root.fake_input("key_press", 64)
        -- root.fake_input("key_press", 21)
        -- root.fake_input("key_release", 21)
        -- root.fake_input("key_release", 64)
        root.fake_input("key_release", 64) -- free modkey
        root.fake_input("key_press", 37)
        root.fake_input("key_press", 15)
        root.fake_input("key_release", 15)
        root.fake_input("key_release", 37)
        root.fake_input("key_press", 64)   -- press back modkey
    else
        mylswitcher.switch()
    end
end

globalkeys = awful.util.table.join(globalkeys,
    awful.key({modkey, }, "space", function () switch_key_layout_vimspecial() end)
)

root.keys(globalkeys)

client.connect_signal("focus", function (c)
    c.border_color = beautiful.border_focus
    -- keep english layout on switching
    if mylswitcher.current == 2 then
        mylswitcher.switch()
    end
end)

-- }}}

--- {{{ telegram toggle
globalkeys = awful.util.table.join(globalkeys,
    awful.key({modkey, }, "t", function () 
        for _, c in ipairs(client.get()) do
            if c ~= nil and c.class == "TelegramDesktop" then
                c:kill()
                return
            end
        end
        awful.util.spawn("telegram-desktop")
        -- Telegrams can start minimized. We should maximize it. But spawn is asynchronous, so we
        -- should wait a little...
        waiter = timer({timeout = 0.05})
        waiter:connect_signal('timeout', function()
            waiter:stop()
            for _, c in ipairs(client.get()) do
                if c ~= nil and c.class == "TelegramDesktop" then
                    client.focus = c
                    c.minimized = false
                    awful.ewmh.activate(c, "", {raise=true})
                    break
                end
            end
        end)
        waiter:start()
    end)
)
--- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


awful.util.spawn_with_shell("if [[ `ps -A | grep xcompmgr | awk '$4 ~ /xcompmgr/ {print 1}'` != 1 ]]; then xcompmgr -cF &>/dev/null & fi")
awful.util.spawn_with_shell("ssh-add /root/.ssh/sun; ssh sun killall gkrellm; ssh sun gkrellm")
