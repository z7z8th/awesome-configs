-- {{{ License
--
-- Awesome configuration, using awesome 3.4.14 on Arch GNU/Linux
--   * Adrian C. <anrxc@sysphere.org>

-- Screenshot: http://sysphere.org/gallery/snapshots

-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}


-- {{{ Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
-- require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- User libraries
local vicious = require("vicious")
local scratch = require("scratch")
-- }}}


function __mydump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. __mydump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function mydump(title, o)
    print(title, __mydump(o))
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
local altkey = "Mod1"
local modkey = "Mod4"

local home   = os.getenv("HOME")
local cfg_path = awful.util.getdir("config")
local run   = awful.util.spawn
local sh_run  = awful.util.spawn_with_shell
local scount = screen.count()

-- Beautiful theme
beautiful.init(cfg_path .. "/themes/bob/theme.lua")
local theme = beautiful.get()
-- mydump("beautiful: ", beautiful)
-- mydump("beautiful.get: ", beautiful.get())

-- Backgroud
sh_run("nitrogen --restore")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
term_run = terminal .. " -e "
editor = os.getenv("EDITOR") or "editor"
editor_cmd = term_run .. editor


-- Window management layouts
layouts = {
  awful.layout.suit.tile,        -- 1
  awful.layout.suit.tile.bottom, -- 2
  awful.layout.suit.fair,        -- 3
  awful.layout.suit.max,         -- 4
  awful.layout.suit.magnifier,   -- 5
  awful.layout.suit.floating     -- 6
}
-- }}}


-- {{{ Tags
tags = {
  -- names  = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
  -- layout = { layouts[6], layouts[6], layouts[6], layouts[6], layouts[6],
  --            layouts[6], layouts[6], layouts[6], layouts[6]
  names  = { " ccccode ", " log ", " web ", " off ", " tttm " },
  layout = { layouts[4], layouts[4], layouts[4], layouts[4], layouts[4]
}}

for s = 1, scount do
  tags[s] = awful.tag(tags.names, s, tags.layout)
  for i, t in ipairs(tags[s]) do
      awful.tag.setproperty(t, "mwfact", 0.5)
      -- awful.tag.setproperty(t, "mwfact", i==5 and 0.13  or  0.5)
      -- awful.tag.setproperty(t, "hide",  (i==6 or  i==7) and true)
  end
end
-- }}}


-- {{{ Menu
function awesome_quit() 
    print("XDG_MENU_PREFIX=", os.getenv("XDG_MENU_PREFIX"))
    if os.getenv("XDG_MENU_PREFIX") == "gnome-" then 
        sh_run("gnome-session-quit --no-prompt --logout") 
    else awesome.quit()
    end 
end

-- Create a laucher widget and a main menu
awesomemenu = {
   { "manual", term_run .. "man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
--   { "themes", thememenu },
   { "restart", awesome.restart },
   { "quit",  awesome_quit }
}

mainmenu = awful.menu({ items = { { "awesome", awesomemenu, theme.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

launcher = awful.widget.launcher({ image = theme.awesome_icon,
                                     menu = mainmenu })
-- }}}

-- {{{ quick launch bar, REF: http://awesome.naquadah.org/wiki/Quick_launch_bar
function find_icon(icon_name, icon_exts, icon_dirs)
    print("find icon: ", icon_name)
    if not icon_name then return nil end
    if string.sub(icon_name, 1, 1) == '/' then
        if awful.util.file_readable(icon_name) then
            return icon_name
        else
            return nil
        end
    end
    local icon_path = awful.util.geticonpath(icon_name, icon_exts, icon_dirs);
    print(icon_name .. " <=> " .. (icon_path or ""))
    return icon_path
 end
 
function getValue(t, key)
    _, _, res = string.find(t, key .. " *= *([^%c]+) *%c?")
    return res
end
 
function get_desktop_items()
    local icon_exts = { "png", "xpm", "svg" }
    local icon_dirs = { "/usr/share/pixmaps", 
                        "/usr/share/icons/hicolor/",
                        "/usr/share/icons/hicolor/32x32/apps/",
                        home .. "/.local/share/icons/hicolor/32x32/apps/",
                        home .. "/.local/share/icons/hicolor/",
                        home .. "/.local/share/icons/" }

    local filedir = home.."/Desktop/" -- Specify your folder with shortcuts here

    local items = {}
    local files = io.popen("ls " .. filedir .. "*.desktop")

    for f in files:lines() do
        print( "\n@@ QuickLaunch: "..f)
        local t = io.open(f):read("*all")
        print("Name="..getValue(t, "Name"))
        print("Exec="..getValue(t, "Exec"))
        local icon = find_icon(getValue(t,"Icon"), icon_exts, icon_dirs) or theme.warn_icon
        print("Icon="..icon)
        table.insert(items, 
                     { image = icon,
                       command = getValue(t,"Exec"),
                       tooltip = getValue(t,"Name"),
                       position = tonumber(getValue(t,"Position")) or 255 })
    end

    table.sort(items, function(a,b) return a.position < b.position end)
    return items
end

local launchbar = {}
local desktop_items = get_desktop_items()
for i,v in ipairs(desktop_items) do
    -- local txt = launchbar[i].tooltip
    launchbar[i] = awful.widget.launcher(v)
    local tt = awful.tooltip ({ objects = { launchbar[i] }, 
                                timer_function = function()
                                    return v.tooltip
                                end
                             })
    -- tt:set_text(txt)
    tt:set_timeout(0)
end
-- }}}

-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = wibox.widget.imagebox(theme.widget_sep)
-- }}}

-- {{{ CPU usage and temperature

ctext = wibox.widget.textbox()
cgraph = awful.widget.graph()
cgraph:set_width(60)
-- cgraph:set_stack(true)
cgraph:set_max_value(100)
cgraph:set_background_color("#494B4F")
cgraph:set_stack_colors({ "#FF5656", "#88A175" })
vicious.cache(vicious.widgets.cpu)
vicious.register(ctext, vicious.widgets.cpu,
                   function (widget, args)
                       cgraph:add_value(args[1], 1) -- Core 1, color 1
                       -- cgraph:add_value(args[3], 2) -- Core 2, color 2
                       return ""
                   end,
                   1)
-- }}}

-- {{{ Battery state
baticon = wibox.widget.imagebox(theme.widget_bat)
-- Initialize widget
batwidget = wibox.widget.textbox()
-- Register widget
-- vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
-- }}}

-- {{{ Memory usage
memicon = wibox.widget.imagebox(theme.widget_mem)
-- Initialize widget
membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_vertical(true):set_ticks(true)
membar:set_width(8):set_ticks_size(2)
membar:set_background_color(theme.fg_off_widget)
membar:set_color({ type = "linear", from = { 0, theme.panel_height }, to = { 0, 0 }, stops = { { 0, theme.fg_widget }, { 0.5, theme.fg_center_widget }, { 1, theme.fg_end_widget } }})
-- membar:set_gradient_colors({ theme.fg_widget,
--    theme.fg_center_widget, theme.fg_end_widget
-- })
-- Register widget
vicious.cache(vicious.widgets.mem)
vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ File system usage
fsicon = wibox.widget.imagebox(theme.widget_fs)
-- Initialize widgets
fs = {
  root = awful.widget.progressbar(), usr = awful.widget.progressbar(),
  opt  = awful.widget.progressbar(), opt2 = awful.widget.progressbar(),
  var  = awful.widget.progressbar(), tmp = awful.widget.progressbar(),
  home = awful.widget.progressbar() 
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_width(5):set_ticks_size(2)
  w:set_border_color(theme.border_widget)
  w:set_background_color(theme.fg_off_widget)
  w:set_color({ type = "linear", from = { 0, theme.panel_height }, to = { 0, 0 }, stops = { { 0, theme.fg_widget }, { 0.5, theme.fg_center_widget }, { 1, theme.fg_end_widget } }})
  -- w:set_gradient_colors({ theme.fg_widget,
  --    theme.fg_center_widget, theme.fg_end_widget
  -- }) 
  -- Register buttons
  w:buttons(awful.util.table.join(
    awful.button({ }, 1, function () run(term_run .. "'watch -n1 df -h'", false) end)
  ))
end -- Enable caching
-- vicious.cache(vicious.widgets.fs)
-- Register widgets
-- vicious.register(fs.root, vicious.widgets.fs, "${/ used_p}", 599)
-- vicious.register(fs.usr, vicious.widgets.fs, "${/usr used_p}",     599)
-- vicious.register(fs.opt, vicious.widgets.fs, "${/opt used_p}",     599)
-- vicious.register(fs.opt2, vicious.widgets.fs, "${/opt2 used_p}",     599)
-- vicious.register(fs.var, vicious.widgets.fs, "${/var used_p}",     599)
-- vicious.register(fs.tmp, vicious.widgets.fs, "${/tmp used_p}",     599)
-- vicious.register(fs.home, vicious.widgets.fs, "${/home used_p}", 599)
-- vicious.register(fs.s, vicious.widgets.fs, "${/mnt/storage used_p}", 599)
-- }}}

-- {{{ Network usage
dnicon = wibox.widget.imagebox(theme.widget_net)
upicon = wibox.widget.imagebox(theme.widget_netup)
-- Initialize widget
netwidget = wibox.widget.textbox()
-- Enable caching
vicious.cache(vicious.widgets.net)
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="'
  .. theme.fg_netdn_widget ..'">${eth1 down_kb}</span> <span color="'
  .. theme.fg_netup_widget ..'">${eth1 up_kb}</span>', 3)
-- }}}

-- {{{ Mail subject
mailicon = wibox.widget.imagebox(theme.widget_mail)
-- Initialize widget
mailwidget = wibox.widget.textbox()
-- Register widget
maildir = home .. "/Mail"
-- vicious.register(mailwidget, vicious.widgets.mdir, "$1", 181, 
--     { maildir .. "/Inbox/",
--       maildir .. "/mantis/", 
--       maildir .. "/gerrit/", 
--       maildir .. "/from-gmail/"})
-- Register buttons
mailwidget:buttons(awful.util.table.join(
  -- awful.button({ }, 1, function () run("urxvt -T Alpine -e alpine.exp") end)
  awful.button({ }, 1, function () run(term_run .. "mutt") end)
))
mailicon:buttons(mailwidget:buttons())
-- }}}

-- {{{ Org-mode agenda
-- orgicon = widget({ type = "imagebox" })
-- orgicon.image = image(theme.widget_org)
-- -- Initialize widget
-- orgwidget = widget({ type = "textbox" })
-- -- Configure widget
-- local orgmode = {
--   files = { home.."/.org/computers.org",
--     home.."/.org/index.org", home.."/.org/personal.org",
--   },
--   color = {
--     past   = '<span color="'..theme.fg_urgent..'">',
--     today  = '<span color="'..theme.fg_normal..'">',
--     soon   = '<span color="'..theme.fg_widget..'">',
--     future = '<span color="'..theme.fg_netup_widget..'">'
-- }} -- Register widget
-- vicious.register(orgwidget, vicious.widgets.org,
--   orgmode.color.past..'$1</span>-'..orgmode.color.today .. '$2</span>-' ..
--   orgmode.color.soon..'$3</span>-'..orgmode.color.future.. '$4</span>', 601,
--   orgmode.files
-- ) -- Register buttons
-- orgwidget:buttons(awful.util.table.join(
--   awful.button({ }, 1, function () run("emacsclient --eval '(org-agenda-list)'") end),
--   awful.button({ }, 3, function () run("emacsclient --eval '(make-remember-frame)'") end)
-- ))
-- }}}

-- {{{ Volume level
volicon = wibox.widget.imagebox(theme.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
-- volwidget = wibox.widget.textbox()
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_width(8):set_ticks_size(2)
volbar:set_background_color(theme.fg_off_widget)
volbar:set_color({ type = "linear", from = { 0, theme.panel_height }, to = { 0, 0 }, stops = { { 0, theme.fg_widget }, { 0.5, theme.fg_center_widget }, { 1, theme.fg_end_widget } }})
-- volbar:set_gradient_colors({ theme.fg_widget,
--    theme.fg_center_widget, theme.fg_end_widget
-- }) 
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
-- vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
-- Register buttons
volbuttons = awful.util.table.join(
   awful.button({ }, 1, function () run(term_run .. "alsamixer") end),
   awful.button({ }, 4, function () run("amixer -c 0 -q set Master 2dB+", false) end),
   awful.button({ }, 5, function () run("amixer -c 0 -q set Master 2dB-", false) end)
)
volicon:buttons(volbuttons)
volbar:buttons(volbuttons)
-- Register assigned buttons
-- volwidget:buttons(volbar:buttons())
-- }}}

-- {{{ Date and time
-- dateicon = wibox.widget.imagebox(theme.widget_date)
-- Initialize widget
datewidget = wibox.widget.textbox()
-- Register widget
vicious.cache(vicious.widgets.date)
vicious.register(datewidget, vicious.widgets.date, "%a %d/%m %R", 61)
-- Register buttons
datebuttons = awful.util.table.join(
  awful.button({ }, 1, function () run(term_run .. "sh -c 'cal -3 && cat'") end)
)
-- dateicon:buttons(datebuttons)
datewidget:buttons(datebuttons)
-- }}}

-- {{{ System tray
systray = wibox.widget.systray()
-- }}}
-- }}}

-- {{{ Task List
tasklist = {}
tasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 800 }
                                                  })
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
-- }}}

-- {{{ Wibox initialisation
function layout_list_add(l, wlist)
    for _,w in pairs(wlist) do
        print(">layout add: ", w, ", ", type(w))
        if w then
            l:add(w)
        end
    end
    return l
end

panel     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
taglist.buttons = awful.util.table.join(
    awful.button({ },        1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ },        3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ },        4, awful.tag.viewnext),
    awful.button({ },        5, awful.tag.viewprev
))

for s = 1, scount do
    -- Create a promptbox
    promptbox[s] = awful.widget.prompt()
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc(1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))

    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)
    -- Create a tasklist widget
    tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist.buttons)

    -- Create the panel
    panel[s] = awful.wibox({ screen = s,
        fg = theme.fg_normal, height = (s == 1 and scount ~= 1 and theme.panel_height or theme.panel_height_large),
        bg = theme.bg_normal, position = "top",
        border_color = theme.border_focus,
        border_width = theme.border_width
    })
    
    ---------------------------------------
    -- Widgets that are aligned to the left
    local left_layout =  wibox.layout.fixed.horizontal()
    -- left_layout:add(launcher)
    left_layout = layout_list_add(left_layout, { launcher,
                                   taglist[s],
                                   layoutbox[s],
                                   separator,
                                   promptbox[s], })
    if s == 1 then
        left_layout = layout_list_add(left_layout, launchbar)
    end
    left_layout:add(separator)

    ----------------------------------------
    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    -- local rotate_layout = wibox.layout.rotate()
    -- rotate_layout:set_direction("west")
    -- rotate_layout:set_widget(cpugraphs[1])
    -- right_layout:add(rotate_layout)

    if s == 2 or scount == 1 then
        right_layout = layout_list_add(right_layout,
            { 
              separator, cgraph,
              -- separator, baticon, batwidget, 
              separator, memicon, membar, 
              -- separator, fsicon, fs.opt, fs.home, fs.opt2,
              -- separator, fs.root, fs.usr, fs.tmp, fs.var,
              separator, dnicon, netwidget, upicon, 
              -- separator, mailicon, mailwidget,
              -- separator, orgicon, orgwidget,  
              separator, volicon, volbar, -- volwidget,
              })
    end
    right_layout = layout_list_add(right_layout, { separator, datewidget })
    if s == 1 then
        right_layout = layout_list_add(right_layout, { separator, systray })
    end

    
    --------------------------------------------------------------
    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(tasklist[s])
    layout:set_right(right_layout)

    -- Add widgets to the panel
    panel[s]:set_widget(layout)
end
-- }}}
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
--
-- @order: false to focus next, true to focus previous
local function focus_curtag_next(order)
   -- print("*****************")
   -- cf = client.focus
   -- print("client.focus: ", cf and cf.name or nil, cf and cf.class or nil)
   local tag = awful.tag.selected()
   local clients = tag:clients()
   -- print("A-Tab: num of clients: ", table.getn(clients))
   -- for i,c in next,clients,nil do
   --    print("i=", i, ", name=", c.name, ", class=", c.class)
   -- end
   local next_client = #clients > 0 and clients[1] or nil
   for i,c in next,clients,nil do
      -- print("c.name=", c.name)
      if c == client.focus then
         if order then
            i = i < #clients and i + 1 or 1
         else
            i = i > 1 and i - 1 or #clients
         end
         next_client = clients[i]
         break
      end
   end
   -- print("=============")
   if next_client then
      -- print("next_client: ", next_client.name, ", ", next_client.class, ", ", next_client:isvisible(), ", ", next_client.ontop)
      awful.client.focus.byidx(0, next_client)
      client.focus = next_client
      next_client:raise()
      next_client.minimized = false
   else
      -- print("next_client: none")
   end
end

-- {{{ Global keys
globalkeys = awful.util.table.join(
    -- {{{ Applications
    awful.key({ modkey }, "e", function () run("emacsclient -n -c") end),
    awful.key({ modkey }, "n", function () run("nautilus", false) end),
    awful.key({ modkey }, "w", function () run("firefox") end),
    awful.key({ altkey }, "F1",  function () run(terminal) end),
    awful.key({ modkey }, "Return", function () run(terminal) end),
    -- awful.key({ altkey }, "#49", function () scratch.drop("urxvt", "bottom", nil, nil, 0.30) end),
    -- awful.key({ modkey }, "a", function () run("urxvt -T Alpine -e alpine.exp") end),
    awful.key({ modkey }, "g", function () sh_run("GTK2_RC_FILES=~/.gtkrc-gajim gajim") end),
    awful.key({ modkey }, "q", function () run("emacsclient --eval '(make-remember-frame)'") end),
    awful.key({ modkey, "Control" }, "l", function () run("xscreensaver-command -lock") end),
    awful.key({ modkey, "Control" }, "s", function () sh_run("xscreensaver-command -lock; sleep 0.5s; sudo pm-suspend;") end),
    awful.key({ altkey }, "#51", function () if boosk then osk(nil, mouse.screen)
        else boosk, osk = pcall(require, "osk") end
    end),
    awful.key({}, "Print", function () sh_run("cd ~/screenshots/; scrot -q 90 -m -e 'mirage \"$f\"';") end),
    awful.key({altkey}, "Print", function () sh_run("cd ~/screenshots/; scrot -q 90 -u -e 'mirage \"$f\"';") end),
    awful.key({"Shift"}, "Print", function () sh_run("cd ~/screenshots/; scrot -q 90 -s -e 'mirage \"$f\"';") end),
    -- }}}

    -- {{{ Multimedia keys
    awful.key({}, "#160", function () run("xscreensaver-command -lock") end),
  -- awful.key({}, "#121", function () run("pvol.py -m") end),
  -- awful.key({}, "#122", function () run("pvol.py -p -c -2") end),
  -- awful.key({}, "#123", function () run("pvol.py -p -c  2") end),
  -- awful.key({}, "#232", function () run("plight.py -s") end),
  -- awful.key({}, "#233", function () run("plight.py -s") end),
  -- awful.key({}, "#150", function () run("sudo /usr/sbin/pm-suspend")   end),
    awful.key({}, "#213", function () run("sudo /usr/sbin/pm-hibernate") end),
  -- awful.key({}, "#235", function () run("xset dpms force off") end),
  -- awful.key({}, "#235", function () run("pypres.py") end),
    awful.key({}, "#244", function () sh_run("acpitool -b | xmessage -timeout 10 -file -")   end),
    -- }}}

    -- {{{ Prompt menus
    awful.key({ altkey }, "F2", function ()
        awful.prompt.run({ prompt = "Run: " }, promptbox[mouse.screen].widget,
            function (...) promptbox[mouse.screen].text = run(unpack(arg), false) end,
            awful.completion.shell, awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ altkey }, "F3", function ()
        awful.prompt.run({ prompt = "Dictionary: " }, promptbox[mouse.screen].widget,
            function (words)
                sh_run("crodict "..words.." | ".."xmessage -timeout 10 -file -")
            end)
    end),
    awful.key({ altkey }, "F4", function ()
        awful.prompt.run({ prompt = "Web: " }, promptbox[mouse.screen].widget,
            function (command)
                sh_run("firefox 'http://yubnub.org/parser/parse?command="..command.."'")
                awful.tag.viewonly(tags[scount][3])
            end)
    end),
    awful.key({ altkey }, "F5", function ()
        awful.prompt.run({ prompt = "Lua: " }, promptbox[mouse.screen].widget,
        awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
    end),
    -- }}}

    -- {{{ Awesome controls
    awful.key({ modkey }, "b", function ()
        panel[mouse.screen].visible = not panel[mouse.screen].visible
    end),
    awful.key({ modkey, "Shift" }, "q", awesome_quit),
    awful.key({ modkey, "Control" }, "r", function ()
        promptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
    end),
    -- }}}

    -- {{{ Layout manipulation
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end),
    -- }}}

    -- {{{ Focus controls
    awful.key({ modkey }, "Tab", function () awful.screen.focus_relative(1) end),
    awful.key({ modkey }, "s", function () scratch.pad.toggle() end),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "j", function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "k", function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ altkey }, "Tab", function ()
        focus_curtag_next(false)
    end),
    awful.key({ altkey, "Shift" }, "Tab", function ()
        focus_curtag_next(true)
    end),
    awful.key({ altkey }, "Escape", function ()
        awful.menu.menu_keys.down = { "Down", "Alt_L" }
        local cmenu = awful.menu.clients({theme.client_menu_width}, { keygrabber=true, coords=theme.client_menu_coord })
    end),
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1)  end),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end)
    -- }}}
)
-- }}}

-- {{{ Client manipulation
clientkeys = awful.util.table.join(
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey }, "c", function (c) awful.client.focus.byidx(1); c:kill() end),
    awful.key({ modkey }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        -- c.maximized_vertical   = not c.maximized_vertical
        c.maximized_vertical   = c.maximized_horizontal
        awful.client.floating.set(c, false)
    end),
    awful.key({ modkey }, "o",     awful.client.movetoscreen),
    awful.key({ modkey }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
    awful.key({ modkey, "Control"},"r", function (c) c:redraw() end),
    awful.key({ modkey, "Shift" }, "0", function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift" }, "m", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift" }, "c", function (c) run("kill -CONT " .. c.pid) end),
    awful.key({ modkey, "Shift" }, "s", function (c) run("kill -STOP " .. c.pid) end),
    awful.key({ modkey, "Shift" }, "t", function (c)
        if   c.titlebar then awful.titlebar.remove(c)
        else
            local ttbar = awful.titlebar(c, { modkey = modkey })
            local title = awful.titlebar.widget.titlewidget(c)
            title:set_text(c.name)
            ttbar:set_widget(title)
        end
    end),
    awful.key({ modkey, "Shift" }, "f", function (c) if awful.client.floating.get(c)
        then awful.client.floating.delete(c);    awful.titlebar.remove(c)
        end
        -- else awful.client.floating.set(c, true); awful.titlebar.add(c) end
    end)
)

-- Client bindings
clientbuttons = awful.util.table.join(
    awful.button({ },        1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Keyboard digits
local keynumber = 0
for s = 1, scount do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end
-- }}}

-- {{{ Tag controls
for i = 1, keynumber do
    globalkeys = awful.util.table.join( globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then awful.tag.viewonly(tags[screen][i]) end
        end),
        awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then awful.tag.viewtoggle(tags[screen][i]) end
        end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
            end
        end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.toggletag(tags[client.focus.screen][i])
            end
        end))
end
-- }}}

-- {{{ Screen controls
for i = 1, scount do
   globalkeys = awful.util.table.join( globalkeys,
                    awful.key({ modkey }, "F" .. i, function () awful.screen.focus(i) 
                end))
end
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules

-- xprop:
-- Firefox 
-- WM_WINDOW_ROLE(STRING) = "browser"
-- WM_NAME(STRING) = "xorg - How to set instance name of google-chrome (or any x11 application) - Super User - Pentadactyl"
-- WM_CLASS(STRING) = "Navigator", "Firefox"
-- WM_CLASS(STRING) = instance, class
--WM_WINDOW_ROLE(STRING) = "3pane"
-- WM_NAME(STRING) = "Inbox - Mozilla Thunderbird"
-- WM_CLASS(STRING) = "Mail", "Thunderbird"


awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons }
    },
    { rule = { instance = "Navigator" },
      properties = { tag = tags[mouse.screen][3], switchtotag = true } },
    { rule = { instance = "Mail" },
      properties = { tag = tags[mouse.screen][4], switchtotag = true } },
    -- { rule = { class = "Evince" },
    --   properties = { tag = tags[mouse.screen][4], switchtotag = true } },
    { rule = { class = "Skype" },
      properties = { tag = tags[mouse.screen][4], floating = true, switchtotag = true } },
    -- { rule = { class = "Emacs",    instance = "emacs" },
    --   properties = { tag = tags[1][2] } },
    -- { rule = { class = "Emacs",    instance = "_Remember_" },
    --   properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { class = "Xmessage", instance = "xmessage" },
      properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { instance = "plugin-container" },
      properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { class = "Wine" },  properties = { focus = false } },
    { rule = { class = "gimp" },  properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    if not awesome.startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
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

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}



-- http://awesome.naquadah.org/wiki/Autostart
-- auto start with dex: https://github.com/jceb/dex
awful.util.spawn_with_shell("$HOME/bin/dex -a -e Awesome")
