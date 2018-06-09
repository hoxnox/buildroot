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
local vicious = require("vicious")
--local vicious.widgets.cpu = require("/home/hoxnox/.config/awesome/cpu.lua")
local hotkeys_popup = require("awful.hotkeys_popup").widget

awsomox = require("awsomox")

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
terminal = "xterm"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	{ "restart", awesome.restart },
	-- { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = {
                                   { "terminal", terminal },
                                   { "awesome", myawesomemenu, beautiful.awesome_icon }}
})

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

wibox_widget_height = 16
wibox_widget_width  = 18

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

local tray = wibox.widget.systray()
-- tray.set_base_size(32)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local horiz_spaced = wibox.layout.fixed.horizontal()
horiz_spaced.spacing = 10
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "⠁", "⠂", "⠃", "⠄", "⠅", "⠋", "⠇", "⠈", "⠉" }, s, awful.layout.layouts[1])
    local tags = root.tags()
    for i = 1, #tags do
        tags[i].master_width_factor = 0.55
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = wibox_widget_height + 2 })

    -- Add widgets to the wibox
    s.mywibox:setup
    {
        layout = wibox.layout.align.horizontal,
        {
            id = "left",
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        {
            id = "right",
            memory,
            arcload,
            layout = horiz_spaced,
            mytextclock,
            mylswitcher,
            tray,
        },
    }
end)
-- }}}

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
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
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
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Shift" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, Shift     }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            --c.floating = false
            --c.maximized_horizontal = false
            --c.maximized_vertical = false
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     --floating = false
                     maximized_horizontal = false,
                     maximized_vertical = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "keepassxc",
          "Pavucontrol",
          "Arandr",
          "Gpick",
          "Kruler",
          "Pidgin",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
          "toolbox_window" -- dia
        }
      }, properties = { floating = true, ontop = true}},
--      { rule_any = { name = { "Telegram" } }, properties = {maximized_horizontal = false, maximized_vertical = false}},
      {
        rule_any = { class = { "TelegramDesktop" } }, 
          properties = {floating = true, ontop = true, sticky = true},
          callback = function(c) 
            c:geometry({x = 700, y = 150})
          end
      },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "dialog" }, class = window_controlls_apps}, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
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

