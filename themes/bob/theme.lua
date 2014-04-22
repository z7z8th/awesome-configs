-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
--    License:  GNU GPL v2   --
-------------------------------

local awful = require("awful")

-- {{{ Main
default_theme_dir = "/usr/share/awesome/themes/default/"
theme = {}
theme.confdir       = awful.util.getdir("config") .. "/themes/bob/"
theme.wallpaper_cmd = { "/usr/bin/nitrogen --restore" }
--theme.wallpaper_cmd = { "awsetbg /usr/share/awesome/themes/zenburn/zenburn-background.png" }
-- }}}


-- {{{ Styles
theme.font      = "Droid Sans Mono 10"

-- {{{ Colors
theme.bg_normal     = "#222222"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

-- }}}

-- {{{ Borders
theme.border_width  = 1
theme.border_focus  = "#535d6c"
theme.border_normal = "#000000"
theme.border_marked = "#91231c"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = theme.bg_normal
theme.titlebar_bg_normal = theme.bg_normal
-- theme.titlebar_[normal|focus]
-- }}}

-- {{{ Widgets
theme.fg_widget        = "#AECF96"
theme.fg_center_widget = "#88A175"
theme.fg_end_widget    = "#FF5656"
theme.fg_off_widget    = "#494B4F"
theme.fg_netup_widget  = "#7F9F7F"
theme.fg_netdn_widget  = "#EE9F7F"
theme.bg_widget        = theme.bg_normal
theme.border_widget    = theme.bg_normal
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- {{{ Mouse finder
theme.mouse_finder_color = theme.fg_urgent
-- theme.mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Taglist icons
-- Display the taglist squares
theme.taglist_squares_sel   = theme.confdir .. "/taglist/squarefw.png"
theme.taglist_squares_unsel = theme.confdir .. "/taglist/squarew.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Menu
-- theme.menu_[bg|fg]_[normal|focus]
-- theme.menu_[height|width|border_color|border_width]
theme.menu_height = 15
theme.menu_width  = 100
theme.client_menu_width  = 100
theme.client_menu_coord = { x=525, y=330 }
-- }}}

-- {{{ Panel
theme.panel_height = 22
theme.panel_height_large = theme.panel_height + 3
theme.panel_height_huge = 32
-- }}}
-- }}}


-- {{{ Icons
-- {{{ Title Bar
theme.titlebar_close_button_normal = theme.confdir .. "/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = theme.confdir .. "/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = theme.confdir .. "/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = theme.confdir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme.confdir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = theme.confdir .. "/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = theme.confdir .. "/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = theme.confdir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme.confdir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = theme.confdir .. "/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = theme.confdir .. "/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = theme.confdir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme.confdir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = theme.confdir .. "/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = theme.confdir .. "/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme.confdir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = theme.confdir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = theme.confdir .. "/titlebar/maximized_focus_active.png"
-- }}} title bar

-- {{{ Layout icons
-- You can use your own layout icons like this:
theme.layout_fairh = theme.confdir .. "/layouts/fairhw.png"
theme.layout_fairv = theme.confdir .. "/layouts/fairvw.png"
theme.layout_floating  = theme.confdir .. "/layouts/floatingw.png"
theme.layout_magnifier = theme.confdir .. "/layouts/magnifierw.png"
theme.layout_max = theme.confdir .. "/layouts/maxw.png"
theme.layout_fullscreen = theme.confdir .. "/layouts/fullscreenw.png"
theme.layout_tilebottom = theme.confdir .. "/layouts/tilebottomw.png"
theme.layout_tileleft   = theme.confdir .. "/layouts/tileleftw.png"
theme.layout_tile = theme.confdir .. "/layouts/tilew.png"
theme.layout_tiletop = theme.confdir .. "/layouts/tiletopw.png"
theme.layout_spiral  = theme.confdir .. "/layouts/spiralw.png"
theme.layout_dwindle = theme.confdir .. "/layouts/dwindlew.png"
-- }}}

-- {{{ Widget icons
theme.widget_cpu    = theme.confdir .. "/icons/cpu.png"
theme.widget_bat    = theme.confdir .. "/icons/bat.png"
theme.widget_mem    = theme.confdir .. "/icons/mem.png"
theme.widget_fs     = theme.confdir .. "/icons/disk.png"
theme.widget_net    = theme.confdir .. "/icons/down.png"
theme.widget_netup  = theme.confdir .. "/icons/up.png"
theme.widget_wifi   = theme.confdir .. "/icons/wifi.png"
theme.widget_mail   = theme.confdir .. "/icons/mail.png"
theme.widget_vol    = theme.confdir .. "/icons/vol.png"
theme.widget_org    = theme.confdir .. "/icons/cal.png"
theme.widget_date   = theme.confdir .. "/icons/time.png"
theme.widget_crypto = theme.confdir .. "/icons/crypto.png"
theme.widget_sep    = theme.confdir .. "/icons/separator.png"
-- }}}

-- {{{ Misc icons
theme.awesome_icon           = theme.confdir .. "/awesome-icon.png"
theme.menu_submenu_icon      = default_theme_dir .. "submenu.png"
theme.tasklist_floating_icon = default_theme_dir .. "tasklist/floatingw.png"
theme.warn_icon              = theme.confdir .. "/icons/warn.png"
-- }}}

-- Define the icon theme for application icons. If not set then the icons 
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil
-- }}}


return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
