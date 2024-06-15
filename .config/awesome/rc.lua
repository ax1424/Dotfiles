local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious") 

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
naughty.config.defaults['icon_size'] = 100
local lain          = require("lain")
local freedesktop   = require("freedesktop")

-- Hotkey Menu
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
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

-- Function to store the current tag index
 local function store_current_tag()
    local tag = awful.screen.focused().selected_tag
    if tag then
        local tag_index = tag.index
        -- Store the tag index in a file
        local file = io.open(gears.filesystem.get_xdg_cache_home() .. "current_tag", "w")
        if file then
            file:write(tag_index)
            file:close()
        end
    end
end
-- Connect store_current_tag function to the awesome.quit signal
awesome.connect_signal("exit", store_current_tag)
-- Function to restore the tag
local function restore_tag()
    -- Read the tag index from the file
    local file = io.open(gears.filesystem.get_xdg_cache_home() .. "current_tag", "r")
    if file then
        local tag_index = tonumber(file:read("*all"))
        file:close()

        -- Switch to the tag with the read index
        if tag_index then
            local screen = awful.screen.focused()
            local tag = screen.tags[tag_index]
            if tag then
                tag:view_only()
            end
        end
    end
end
-- Call restore_tag function during startup
awful.spawn.with_shell("sleep 0.1 && awesome-client 'awesome.emit_signal(\"startup_done\")'")
awesome.connect_signal("startup_done", restore_tag)

-- Import The Theme
beautiful.init("~/.config/awesome/theme.lua")
	
-- Define a few variables
local modkey      = "Mod4"
local altkey      = "Mod1"
local ctrlkey     = "Control"
local terminal    = "alacritty"

-- Tags
local names={"1", "2", "3", "4", "5", "6", "7", "8"}
--local names={"", "", "", "", "", "", "", ""}
--local names={"WEB", "DEV", "SYS", "DOC", "VBOX", "MUS", "VID", "GFX"}
local l = awful.layout.suit
local layouts = {l.tile,l.tile,l.tile,l.tile,l.tile,l.tile,l.tile,l.tile} --Set a Layout for each Tag
awful.tag(names,s,layouts)
	
-- Define a few layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating,
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
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}


---WIDGETS---

-- Create a separator widget
local separator = wibox.widget {
widget = wibox.widget.textbox,
text = '|',
align = 'center',
valign = 'center',
}

local awesome_icon = wibox.widget.imagebox("/home/aston/.config/awesome/icons/awesome_icon.png")
awesome_icon:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- Left mouse button
        awful.spawn("alacritty") 
    end
end)

 -- WiFi widget
local wifi_widget = wibox.widget.textbox()
local interface = "wlan0" -- Replace with your network interface name
vicious.register(wifi_widget, vicious.widgets.net, 
      function (widget, args)
          return string.format("📡:%s ↓↑ %s", args["{" .. interface .. " down_kb}"],
           args["{" .. interface .. " up_kb}"])
      end, 2)
    
-- Battery widget
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat, "🔋:$2%", 61, "BAT0")

-- CPU widget
mycpu = wibox.widget.textbox()
vicious.register(mycpu, vicious.widgets.cpu, "⚙️:$1%", 3)

-- Memory widget 
local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, function(widget, args)
    local used = args[2]  -- Used memory in MB
    local percent = args[1]  -- Percentage of used memory
    return string.format("🖥️:%.0fM (%.0f%%)", used, percent)
end, 13)
mem_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- Left mouse button
        awful.spawn("alacritty -e htop")
    end
end)

--Clock widget
mytextclock = wibox.widget.textclock("📅:%a, %b %d - %I:%M %p")

-- Function to get the total number of installed packages
local function get_package_count()
    local handle = io.popen("pacman -Q | wc -l")
    local result = handle:read("*a")
    handle:close()
    return tonumber(result)
end

-- Package Count Widget
local package_widget = wibox.widget {
    {
        id = "txt",
        widget = wibox.widget.textbox,
        font = "MononokiNerdFont Mono 12"
    },
    layout = wibox.container.margin,
    set_count = function(self, count)
        self:get_children_by_id("txt")[1].text = "📦:" .. count
    end
}
local function update_package_widget()
    package_widget:set_count(get_package_count())
end
gears.timer {
    timeout = 86400,
    autostart = true,
    callback = update_package_widget
}
update_package_widget()

-- Uptime widget t
local uptime_icon = wibox.widget.textbox("⏳")
local uptime_widget = wibox.widget.textbox()
vicious.register(uptime_widget, vicious.widgets.uptime, function(widget, args)
    if args[1] > 0 then
        return string.format(":%dd", args[1])
    elseif args[2] > 0 then
        return string.format(":%dh", args[2])
    else
        return string.format(":%dm", args[3])
    end
end, 61)
local myuptime = wibox.widget {
    uptime_icon,
    uptime_widget,
    layout = wibox.layout.fixed.horizontal,
}

-- Update Widget
local update_widget = wibox.widget.textbox()
local function update_check(widget)
    awful.spawn.easy_async_with_shell("checkupdates | wc -l", function(stdout)
        local updates = tonumber(stdout) or 0
        widget.text = "🔄: " .. updates
    end)
end
update_check(update_widget)
gears.timer {
    timeout   = 86400,  -- Check for updates every 24 hours
    call_now  = true,
    autostart = true,
    callback  = function() update_check(update_widget) end
}
update_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- Left mouse button
        awful.spawn.easy_async_with_shell("/home/aston/.config/awesome/scripts/sys_update.sh", function(stdout, stderr, exitreason, exitcode)
            -- Handle completion or errors if needed
            if exitcode == 0 then
                -- Update succeeded
                naughty.notify({title = "System Update", text = "Update completed successfully", timeout = 5})
            else
                -- Update failed
                naughty.notify({title = "System Update", text = "Update failed", timeout = 5})
            end
        end)
    end
end)


-- Volume Widget
local volume_widget = wibox.widget.textbox()
vicious.register(volume_widget, vicious.widgets.volume, "🔊:$1%", 2, "Master")
volume_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- Left mouse button
        awful.spawn("pavucontrol")
    end
end)

local systray = wibox.widget.systray()
systray.base_size = 28
local systray_centered = wibox.container.place(systray)
systray_centered.valign = "center"


-- Define the colors
local colors = { "#003C8C", "#6D4A9C" }
local spacing = 2

-- Function to create a widget with a background and margin
local function create_widget(widget, color)
    return wibox.container.background(
        wibox.container.margin(widget, spacing, spacing),
        color
    )
end

-- Create widgets with alternating colors
mytextclock = create_widget(mytextclock, colors[2])
mybattery = create_widget(mybattery, colors[2])
wifi_widget = create_widget(wifi_widget, colors[1])
mycpu = create_widget(mycpu, colors[2])
mem_widget = create_widget(mem_widget, colors[1])
package_widget = create_widget(package_widget, colors[2])
update_widget = create_widget(update_widget, colors[1])
myuptime = create_widget(myuptime, colors[2], true)
volume_widget = create_widget(volume_widget, colors[1])

--Widget Spacing
mybattery = wibox.container.margin(mybattery, spacing, spacing)
wifi_widget = wibox.container.margin(wifi_widget, spacing, spacing)
mycpu = wibox.container.margin(mycpu, spacing, spacing)
mem_widget = wibox.container.margin(mem_widget, spacing, spacing)
package_widget = wibox.container.margin(package_widget, spacing, spacing)
update_widget = wibox.container.margin(update_widget, spacing, spacing)
myuptime = wibox.container.margin(myuptime, spacing, spacing)
mytextclock = wibox.container.margin(mytextclock, spacing, spacing)
volume_widget = wibox.container.margin(volume_widget, spacing, spacing)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
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

local tasklist_buttons = gears.table.join(
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

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({
    position = "top",
    screen = s,
    bg = "#282a36",  -- Set the background color of the wibox
    fg = "#FFFFFF"  -- Optional: Set the foreground color
    --bg = "#000000bb",
      })

	-- Tasklist Filter Function
local function only_focused(c, screen)
    return c == client.focus
end

-- Create a Tasklist Widget
mytasklist = awful.widget.tasklist {
    screen = s,
    filter = only_focused,
    buttons = awful.util.tasklist_buttons,
    style = {
        shape = gears.shape.bar,
    },
    layout = {
        spacing = 5,
        layout = wibox.layout.flex.horizontal
    },
    widget_template = {
        {
            {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            left  = 10,
            right = 10,
            widget = wibox.container.margin
        },
        id     = 'background_role',
        widget = wibox.container.background,
        create_callback = function(self, c, index, objects) --luacheck: no unused
            self:get_children_by_id('text_role')[1].markup = '<b>' .. c.name .. '</b>'
        end,
        update_callback = function(self, c, index, objects) --luacheck: no unused
            self:get_children_by_id('text_role')[1].markup = '<b>' .. c.name .. '</b>'
        end,
    },
}

    -- Set up the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            awesome_icon,
            s.mytaglist,
            separator,
            s.mylayoutbox,
            separator,
            s.mypromptbox,
        },
        mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            mybattery,
            wifi_widget,
            mycpu,
            mem_widget,
            package_widget,
            update_widget,
            myuptime,
            volume_widget,
            mytextclock,       
            --table.unpack(mywidgets),
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
   -- awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,   		  }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

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
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, 	    }, "p", 		 function () 
              awful.spawn.with_shell("~/ro-scripts/sys_menu.sh") end,
              {description = "system menu", group = "awesome"}), 

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
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
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

	--- ESSENTIAL KEYBINDINGS ---
	
    -- Rofi
    awful.key({ modkey, "Shift" },            "Return",     function () 
    awful.util.spawn("rofi -show drun") end,
              {description = "run rofi", group = "launcher"}),
    -- Active Windows
    awful.key({ altkey },            "Tab",     function () 
    awful.util.spawn("rofi -show window") end,
              {description = "show active windows", group = "launcher"}),
    -- SSH
    awful.key({ modkey, "Shift" },            "s",     function () 
    awful.util.spawn("rofi -show ssh") end,
              {description = "run ssh", group = "launcher"}),  
    -- Filebrowser
    awful.key({ modkey,  },            "r",     function () 
    awful.util.spawn("rofi -show filebrowser") end,
              {description = "browse files with rofi", group = "utilities"}),  
    -- Wallpaper Selector 
    awful.key({ modkey,  },            "b",     function () 
    awful.spawn.with_shell("~/ro-scripts/wallpaper.sh") end,
              {description = "select a wallpaper with rofi", group = "launcher"}),
    -- Floorp
    awful.key({ modkey },            "w",     function () 
    awful.util.spawn("floorp") end,
              {description = "web browser", group = "internet"}),
    -- Thunar
    awful.key({ modkey, "Shift" },            "f",     function () 
    awful.util.spawn("thunar") end,
              {description = "thunar", group = "utilities"}),
    -- Geany
    awful.key({ modkey },            "g",     function () 
    awful.util.spawn("geany") end,
              {description = "geany", group = "development"}),
    -- Awesome Config File
    awful.key({ modkey },            "c",     function () 
    awful.util.spawn("geany /home/aston/.config/awesome/rc.lua") end,
              {description = "geany", group = "development"}),           
	-- Virt-Manager
    awful.key({ modkey, "Shift" },            "v",     function () 
    awful.util.spawn("virt-manager") end,
              {description = "virt-manager", group = "utilities"}),                    	          
    -- Pavucontrol
    awful.key({ modkey, },            "v",     function () 
    awful.util.spawn("pavucontrol") end,
              {description = "volume control", group = "audio"}),
    -- Deadbeef
    awful.key({ modkey,  },            "d",     function () 
    awful.util.spawn("deadbeef") end,
              {description = "music player", group = "audio"}),
    -- Thunderbird Email Client 
    awful.key({ modkey, },            "t",     function () 
    awful.util.spawn("thunderbird") end,
              {description = "email client", group = "mail"}), 
    -- OnlyOffice
    awful.key({ modkey, },            "o",     function () 
    awful.util.spawn("onlyoffice-desktopeditors") end,
              {description = "office suite", group = "office"}), 
	-- Brightness control
	awful.key({ }, 			"XF86MonBrightnessUp", 		function ()
    awful.util.spawn("brightnessctl set +10%") end, -- Increase brightness by 10%
			{description = "increase brightness", group = "screen"}),
	awful.key({ }, 			"XF86MonBrightnessDown", 	function ()
    awful.util.spawn("brightnessctl set 10%-") end, -- Decrease brightness by 10%
     {description = "decrease brightness", group = "screen"}),
	-- Volume control
	awful.key({ctrlkey, },    "F3", 			 function ()
    awful.util.spawn("amixer set Master 5%+") end,
			{description = "increase volume", group = "audio"}),
	awful.key({ctrlkey, },	 "F2", 		function ()
    awful.util.spawn("amixer set Master 5%-") end, 
			{description = "decrease volume", group = "audio"}),
	awful.key({ctrlkey, }, 	 "F4",		 function ()
    awful.util.spawn("amixer set Master toggle") end,
			 {description = "mute volume", group = "audio"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,  		  }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
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
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
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

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

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
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
		"galculator",
        },
        class = {
          },

        name = {
          },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          }
      }, properties = { floating = true }},
      
      -- Set Apps to Spawn on Specific Workspaces 

    -- Set Floorp to always spawn on tag "1" on screen 1.
     { rule = { class = "floorp" },
       properties = { screen = 1, tag = "1" } },
    -- Set Geany to always spawn on tag "2" on screen 1.
     { rule = { class = "Geany" },
       properties = { screen = 1, tag = "2" } },
    -- Set Thunderbird to always spawn on tag "3" on screen 1.
     { rule = { class = "thunderbird" },
       properties = { screen = 1, tag = "3" } },
    -- Set OnlyOffice to always spawn on tag "4" on screen 1.
     { rule = { class = "ONLYOFFICE" },
       properties = { screen = 1, tag = "4" } },
    -- Set Virt-Manager to always spawn on tag "5" on screen 1.
     { rule = { class = "Virt-manager" },
       properties = { screen = 1, tag = "5" } },
    -- Set Lollypop to always spawn on tag "6" on screen 1.
     { rule = { class = "Deadbeef" },
       properties = { screen = 1, tag = "6" } },

}


-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
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

-- Autostart script (wallpaper, compositor, etc.)
awful.spawn.with_shell("~/.config/awesome/scripts/autostart.sh")
