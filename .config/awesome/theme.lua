local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font          = "Ubuntu Mono 12"

theme.bg_normal     = "#282a36"
theme.bg_focus      = "#282a36"
theme.bg_urgent     = "#46d9ff"
theme.bg_minimize   = "#282a36"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#FFFFFF"
theme.fg_focus      = "#46d9ff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"
theme.taglist_focus                             = "#FFFFFF"
theme.taglist_bg_focus                          = "#1c1f24"
theme.taglist_bg_normal                         = "#282a36"
theme.mytasklist_focus							= "#FFFFFF"
theme.mytasklist_bg_focus						= "#9676C5"
theme.mytasklist_bg_normal						= "#282a36"

theme.useless_gap   = dpi(4)
theme.border_width  = dpi(2)
theme.border_normal = "#282a36"
theme.border_focus  = "#46d9ff"
theme.border_marked = "#91231c"

theme.hotkeys_modifiers_fg = "#FFFFFF"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
local taglist_square_size = dpi(6)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- You can use your own layout icons like this:
theme.layout_floating  = "~/.config/awesome/icons/floating.png"
theme.layout_max = "~/.config/awesome/icons/max.png"
theme.layout_fullscreen = "~/.config/awesome/icons/fullscreen.png"
theme.layout_tile = "~/.config/awesome/icons/tile.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
