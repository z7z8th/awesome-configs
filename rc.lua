-- {{{ License
--
-- Awesome configuration, using awesome 3.4.14 on Arch GNU/Linux
--   * Adrian C. <anrxc@sysphere.org>

-- Screenshot: http://sysphere.org/gallery/snapshots

-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}


-- {{{ Libraries
require("awful")
require("awful.rules")
--require("awful.autofocus")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Load Debian menu entries
require("debian.menu")


-- User libraries
vicious = require("vicious")
scratch = require("scratch")
-- }}}

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
    awesome.add_signal("debug::error", function (err)
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
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell
local scount = screen.count()

-- Beautiful theme
beautiful.init(home .. "/.config/awesome/zenburn.lua")

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
-- tags = {
--   names  = { "term", "emacs", "web", "mail", "im", 6, 7, "rss", "media" },
--   layout = { layouts[2], layouts[1], layouts[1], layouts[4], layouts[1],
--              layouts[6], layouts[6], layouts[5], layouts[6]
-- }}
tags = {
  -- names  = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
  -- layout = { layouts[6], layouts[6], layouts[6], layouts[6], layouts[6],
  --            layouts[6], layouts[6], layouts[6], layouts[6]
  names  = { "term ", "log ", "web ", "ref ", "cod" },
  layout = { layouts[1], layouts[1], layouts[4], layouts[1], layouts[4]
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

-- Menu for theme --
thememenu = {}

function theme_load(theme)
   local cfg_path = awful.util.getdir("config")

   -- Create a symlink from the given theme to /home/user/.config/awesome/current_theme
   awful.util.spawn("ln -sfn " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/current_theme")
   awesome.restart()
end

function theme_menu()
   -- List your theme files and feed the menu table
   local cmd = "ls -1 " .. awful.util.getdir("config") .. "/themes/"
   local f = io.popen(cmd)

   for l in f:lines() do
	  local item = { l, function () theme_load(l) end }
	  table.insert(thememenu, item)
   end

   f:close()
end

-- Generate your table at startup or restart
-- theme_menu()

-- Create a laucher widget and a main menu
awesomemenu = {
   { "manual", term_run .. "man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
--   { "themes", thememenu },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mainmenu = awful.menu({ items = { { "awesome", awesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

launcher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mainmenu })
-- }}}

-- {{{ quick launch bar, REF: http://awesome.naquadah.org/wiki/Quick_launch_bar
local icon_exts = { "png", "xpm", "svg" }
 
 -- Quick launch bar widget BEGINS
function find_icon(icon_name, icon_dirs)
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
   _, _, res = string.find(t, key .. " *= *([^%c]+)%c")
    return res
 end
 
 launchbar = { ["layout"] = awful.widget.layout.horizontal.leftright }
 filedir = home.."/Desktop/" -- Specify your folder with shortcuts here
 local items = {}
 local files = io.popen("ls " .. filedir .. "*.desktop")
 for f in files:lines() do
    print( "@@ QuickLaunch: "..f)
    local t = io.open(f):read("*all")
    print("Exec="..getValue(t, "Exec"))
    print("Name="..getValue(t, "Name"))
    table.insert(items, { image = find_icon(getValue(t,"Icon"), 
					    { "/usr/share/pixmaps", 
					      "/usr/share/icons/hicolor/",
					      home .. "/.local/share/icons/hicolor/32x32/apps/",
					      home .. "/.local/share/icons/hicolor/",
					      home .. "/.local/share/icons/"}),
			  command = getValue(t,"Exec"),
			  tooltip = getValue(t,"Name"),
			  position = tonumber(getValue(t,"Position")) or 255 })
 end
 table.sort(items, function(a,b) return a.position < b.position end)
 for i = 1, table.getn(items) do
    print("@@ Got Items:", i)
    --     local txt = launchbar[i].tooltip
    launchbar[i] = awful.widget.launcher(items[i])
    --     local tt = awful.tooltip ({ objects = { launchbar[i] } })
    --     tt:set_text (txt)
    --     tt:set_timeout (0)
 end
 
 -- Quick launch bar widget ENDS

-- }}}

-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)
-- }}}

-- {{{ CPU usage and temperature
function get_cpucount()
    local s = 0
    local cpuinfo = io.open("/proc/cpuinfo")
    if cpuinfo then
        for line in cpuinfo:lines() do
            for processor in string.gmatch(line, "processor%s*:%s*%d+") do
                s = s + 1
            end
        end
    end
    return s
end

cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
cpucount = get_cpucount()
cpuids = {}
cpugraphs = {}
tzswidgets = {}
if cpucount >= 4 then cpucount = cpucount / 2 end
for s = 1, cpucount do
    -- Initialize widgets
    cpugraphs[s]  = awful.widget.graph()
    tzswidgets[s] = widget({ type = "textbox" })
    cpuids[s] = widget({ type = "textbox" })
    cpuids[s].text = tostring(s) 
    -- Graph properties
    cpugraphs[s]:set_width(40):set_height(18)
    cpugraphs[s]:set_background_color(beautiful.fg_off_widget)
    cpugraphs[s]:set_gradient_angle(0):set_gradient_colors({
    beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
    })
    -- Register widgets
    vicious.register(cpugraphs[s],  vicious.widgets.cpu,     "$" .. (s+"1"))
    vicious.register(tzswidgets[s], vicious.widgets.thermal, "$1C", 19, "thermal_zone" .. (s-"1"))
end
-- }}}

-- {{{ Battery state
baticon = widget({ type = "imagebox" })
baticon.image = image(beautiful.widget_bat)
-- Initialize widget
batwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
-- }}}

-- {{{ Memory usage
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_vertical(true):set_ticks(true)
membar:set_height(12):set_width(8):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Register widget
vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ File system usage
fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.widget_fs)
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
  w:set_height(18):set_width(5):set_ticks_size(2)
  w:set_border_color(beautiful.border_widget)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_gradient_colors({ beautiful.fg_widget,
     beautiful.fg_center_widget, beautiful.fg_end_widget
  }) -- Register buttons
  w.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () exec(term_run .. "'watch -n1 df -h'", false) end)
  ))
end -- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.root, vicious.widgets.fs, "${/ used_p}", 599)
vicious.register(fs.usr, vicious.widgets.fs, "${/usr used_p}",     599)
vicious.register(fs.opt, vicious.widgets.fs, "${/opt used_p}",     599)
vicious.register(fs.opt2, vicious.widgets.fs, "${/opt2 used_p}",     599)
vicious.register(fs.var, vicious.widgets.fs, "${/var used_p}",     599)
vicious.register(fs.tmp, vicious.widgets.fs, "${/tmp used_p}",     599)
vicious.register(fs.home, vicious.widgets.fs, "${/home used_p}", 599)
-- vicious.register(fs.s, vicious.widgets.fs, "${/mnt/storage used_p}", 599)
-- }}}

-- {{{ Network usage
dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)
-- Initialize widget
netwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="'
  .. beautiful.fg_netdn_widget ..'">${eth0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${eth0 up_kb}</span>', 3)
-- }}}

-- {{{ Mail subject
mailicon = widget({ type = "imagebox" })
mailicon.image = image(beautiful.widget_mail)
-- Initialize widget
mailwidget = widget({ type = "textbox" })
-- Register widget
maildir = home .. "/Mail"
vicious.register(mailwidget, vicious.widgets.mdir, "$1", 181, 
    { maildir .. "/Inbox/",
      maildir .. "/mantis/", 
      maildir .. "/gerrit/", 
      maildir .. "/from-gmail/"})
-- Register buttons
mailwidget:buttons(awful.util.table.join(
  -- awful.button({ }, 1, function () exec("urxvt -T Alpine -e alpine.exp") end)
  awful.button({ }, 1, function () exec(term_run .. "mutt") end)
))
mailicon:buttons(mailwidget:buttons())
-- }}}

-- {{{ Org-mode agenda
-- orgicon = widget({ type = "imagebox" })
-- orgicon.image = image(beautiful.widget_org)
-- -- Initialize widget
-- orgwidget = widget({ type = "textbox" })
-- -- Configure widget
-- local orgmode = {
--   files = { home.."/.org/computers.org",
--     home.."/.org/index.org", home.."/.org/personal.org",
--   },
--   color = {
--     past   = '<span color="'..beautiful.fg_urgent..'">',
--     today  = '<span color="'..beautiful.fg_normal..'">',
--     soon   = '<span color="'..beautiful.fg_widget..'">',
--     future = '<span color="'..beautiful.fg_netup_widget..'">'
-- }} -- Register widget
-- vicious.register(orgwidget, vicious.widgets.org,
--   orgmode.color.past..'$1</span>-'..orgmode.color.today .. '$2</span>-' ..
--   orgmode.color.soon..'$3</span>-'..orgmode.color.future.. '$4</span>', 601,
--   orgmode.files
-- ) -- Register buttons
-- orgwidget:buttons(awful.util.table.join(
--   awful.button({ }, 1, function () exec("emacsclient --eval '(org-agenda-list)'") end),
--   awful.button({ }, 3, function () exec("emacsclient --eval '(make-remember-frame)'") end)
-- ))
-- }}}

-- {{{ Volume level
volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = widget({ type = "textbox" })
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(12):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
-- Register buttons
volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec(term_run .. "alsamixer") end),
   awful.button({ }, 4, function () exec("amixer -q set Master 2dB+", false) end),
   awful.button({ }, 5, function () exec("amixer -q set Master 2dB-", false) end)
)) -- Register assigned buttons
volwidget:buttons(volbar.widget:buttons())
-- }}}

-- {{{ Date and time
dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%a %d/%m %R", 61)
-- Register buttons
datewidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () exec(term_run .. "sh -c 'cal -3 && cat'") end)
))
-- }}}

-- {{{ System tray
systray = widget({ type = "systray" })
-- }}}
-- }}}

-- {{{ Task List
tasklist = {}
tasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
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
-- }}}

-- {{{ Wibox initialisation
wibox     = {}
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
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))

    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
    -- Create a tasklist widget
    tasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, tasklist.buttons)
    -- Create the wibox
    wibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = (s == 1 and scount ~= 1 and 18 or 20),
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.border_focus,
        border_width = beautiful.border_width
    })

    -- Create CPU widgets
    cpulist = {}
    for scpu = cpucount, 1, -1 do
        table.insert(cpulist, { tzswidgets[scpu], cpugraphs[scpu] and cpugraphs[scpu].widget or nil, cpuids[scpu], cpuicon, separator,
                                    ["layout"] = awful.widget.layout.horizontal.rightleft })
    end
    cpulist["layout"] = awful.widget.layout.horizontal.rightleft


    -- Add widgets to the wibox
    wibox[s].widgets = {
        {   launcher, taglist[s], layoutbox[s], separator, promptbox[s],
            ["layout"] = awful.widget.layout.horizontal.leftright
        },
        s == 1 and { launchbar, separator, 
		     ["layout"] = awful.widget.layout.horizontal.leftright } or nil,
        s == 1 and {
            systray, separator,
            ["layout"] = awful.widget.layout.horizontal.rightleft
        } or nil,
        datewidget, dateicon, separator,
        (s == 2 or scount == 1) and {
            volwidget,  volbar.widget, volicon, separator,
            -- separator, orgwidget,  orgicon,
            -- mailwidget, mailicon, separator,
            upicon,     netwidget, dnicon, separator,
            -- fs.home.widget, fs.tmp.widget, fs.var.widget, fs.opt2.widget, separator,
            --             fs.opt.widget, fs.usr.widget, fs.root.widget, fsicon, separator,
            membar.widget, memicon, separator,
            -- batwidget, baticon, separator,
            cpulist,
            ["layout"] = awful.widget.layout.horizontal.rightleft
        } or nil,
        tasklist[s], separator,
        ["layout"] = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Client bindings
clientbuttons = awful.util.table.join(
    awful.button({ },        1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}


-- {{{ Key bindings
--
-- @order: true to focus next, false to focus previous
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
    awful.key({ modkey }, "e", function () exec("emacsclient -n -c") end),
    awful.key({ modkey }, "n", function () exec("nautilus", false) end),
    awful.key({ modkey }, "w", function () exec("firefox") end),
    awful.key({ altkey }, "F1",  function () exec(terminal) end),
    awful.key({ modkey }, "Return", function () exec(terminal) end),
    -- awful.key({ altkey }, "#49", function () scratch.drop("urxvt", "bottom", nil, nil, 0.30) end),
    -- awful.key({ modkey }, "a", function () exec("urxvt -T Alpine -e alpine.exp") end),
    awful.key({ modkey }, "g", function () sexec("GTK2_RC_FILES=~/.gtkrc-gajim gajim") end),
    awful.key({ modkey }, "q", function () exec("emacsclient --eval '(make-remember-frame)'") end),
    awful.key({ modkey, "Control" }, "l", function () exec("xscreensaver-command -lock") end),
    awful.key({ modkey, "Control" }, "s", function () sexec("xscreensaver-command -lock; sleep 0.5s; sudo pm-suspend;") end),
    awful.key({ altkey }, "#51", function () if boosk then osk(nil, mouse.screen)
        else boosk, osk = pcall(require, "osk") end
    end),
    awful.key({}, "Print", function () sexec("scrot -q 90 -e 'mkdir -p ~/screenshots; mv \"$f\" ~/screenshots/'") end),
    awful.key({altkey}, "Print", function () sexec("scrot -q 90 -u -e 'mkdir -p ~/screenshots; mv \"$f\" ~/screenshots/'") end),
    -- }}}

    -- {{{ Multimedia keys
    awful.key({}, "#160", function () exec("xscreensaver-command -lock") end),
  -- awful.key({}, "#121", function () exec("pvol.py -m") end),
  -- awful.key({}, "#122", function () exec("pvol.py -p -c -2") end),
  -- awful.key({}, "#123", function () exec("pvol.py -p -c  2") end),
  -- awful.key({}, "#232", function () exec("plight.py -s") end),
  -- awful.key({}, "#233", function () exec("plight.py -s") end),
  -- awful.key({}, "#150", function () exec("sudo /usr/sbin/pm-suspend")   end),
    awful.key({}, "#213", function () exec("sudo /usr/sbin/pm-hibernate") end),
  -- awful.key({}, "#235", function () exec("xset dpms force off") end),
  -- awful.key({}, "#235", function () exec("pypres.py") end),
    awful.key({}, "#244", function () sexec("acpitool -b | xmessage -timeout 10 -file -")   end),
    -- }}}

    -- {{{ Prompt menus
    awful.key({ altkey }, "F2", function ()
        awful.prompt.run({ prompt = "Run: " }, promptbox[mouse.screen].widget,
            function (...) promptbox[mouse.screen].text = exec(unpack(arg), false) end,
            awful.completion.shell, awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ altkey }, "F3", function ()
        awful.prompt.run({ prompt = "Dictionary: " }, promptbox[mouse.screen].widget,
            function (words)
                sexec("crodict "..words.." | ".."xmessage -timeout 10 -file -")
            end)
    end),
    awful.key({ altkey }, "F4", function ()
        awful.prompt.run({ prompt = "Web: " }, promptbox[mouse.screen].widget,
            function (command)
                sexec("firefox 'http://yubnub.org/parser/parse?command="..command.."'")
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
        wibox[mouse.screen].visible = not wibox[mouse.screen].visible
    end),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "r", function ()
        promptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
    end),
    -- }}}

    -- {{{ Tag browsing
    -- awful.key({ altkey }, "n",   awful.tag.viewnext),
    -- awful.key({ altkey }, "p",   awful.tag.viewprev),
    -- awful.key({ altkey }, "Tab", awful.tag.history.restore),
    -- }}}

    -- {{{ Layout manipulation
    awful.key({ modkey }, "l",          function () awful.tag.incmwfact( 0.05) end),
    awful.key({ modkey }, "h",          function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "l", function () awful.client.incwfact( 0.05) end),
    awful.key({ modkey, "Shift" }, "h", function () awful.client.incwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey },          "space", function () awful.layout.inc(layouts,  1) end),
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
        focus_curtag_next(true)
    end),
    awful.key({ altkey, "Shift" }, "Tab", function ()
        focus_curtag_next(false)
    end),
    awful.key({ altkey }, "Escape", function ()
        awful.menu.menu_keys.down = { "Down", "Alt_L" }
        local cmenu = awful.menu.clients({width=230}, { keygrabber=true, coords={x=525, y=330} })
    end),
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1)  end),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end)
    -- }}}
)
-- }}}

-- {{{ Client manipulation
clientkeys = awful.util.table.join(
    awful.key({ modkey }, "c", function (c) awful.client.focus.byidx(1); c:kill() end),
    awful.key({ modkey }, "d", function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
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
    awful.key({ modkey, "Shift" }, "c", function (c) exec("kill -CONT " .. c.pid) end),
    awful.key({ modkey, "Shift" }, "s", function (c) exec("kill -STOP " .. c.pid) end),
    awful.key({ modkey, "Shift" }, "t", function (c)
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, { modkey = modkey }) end
    end),
    awful.key({ modkey, "Shift" }, "f", function (c) if awful.client.floating.get(c)
        then awful.client.floating.delete(c);    awful.titlebar.remove(c)
        end
        -- else awful.client.floating.set(c, true); awful.titlebar.add(c) end
    end)
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
awful.rules.rules = {
    { rule = { }, properties = {
      focus = true,      size_hints_honor = false,
      keys = clientkeys, buttons = clientbuttons,
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal }
    },
    -- { rule = { class = "Iceweasel",  instance = "Navigator" },
    --   properties = { tag = mouse.screen][3] } },
    -- { rule = { class = "Emacs",    instance = "emacs" },
    --   properties = { tag = tags[1][2] } },
    -- { rule = { class = "Emacs",    instance = "_Remember_" },
    --   properties = { floating = true }, callback = awful.titlebar.add  },
    -- { rule = { class = "Xmessage", instance = "xmessage" },
    --   properties = { floating = true }, callback = awful.titlebar.add  },
    -- { rule = { instance = "plugin-container" },
    --   properties = { floating = true }, callback = awful.titlebar.add  },
    -- { rule = { class = "Akregator" },   properties = { tag = tags[scount][8]}},
    -- { rule = { name  = "Alpine" },      properties = { tag = tags[1][4]} },
    -- { rule = { class = "Gajim" },       properties = { tag = tags[1][5]} },
    -- { rule = { class = "Ark" },         properties = { floating = true } },
    -- { rule = { class = "Geeqie" },      properties = { floating = true } },
    -- { rule = { class = "ROX-Filer" },   properties = { floating = true } },
    -- { rule = { class = "Pinentry.*" },  properties = { floating = true } },
}
-- }}}


-- {{{ Signals
--
-- {{{ Manage signal handler
client.add_signal("manage", function (c, startup)
    -- Add titlebar to floaters, but remove those from rule callback
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
        if   c.titlebar then awful.titlebar.remove(c)
        end
        -- else awful.titlebar.add(c, {modkey = modkey}) end
    end

    -- Enable sloppy focus
    -- c:add_signal("mouse::enter", function (c)
    --     if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    --     and awful.client.focus.filter(c) then
    --         client.focus = c
    --     end
    -- end)

    -- Client placement
    if not startup then
        awful.client.setslave(c)

        if  not c.size_hints.program_position
        and not c.size_hints.user_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
-- }}}

-- {{{ Focus signal handlers
client.add_signal("focus",   function (c) c.border_color = beautiful.border_focus  end)
client.add_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, scount do
    screen[s]:add_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end
-- }}}
-- }}}


-- http://awesome.naquadah.org/wiki/Autostart
-- auto start with dex: https://github.com/jceb/dex
awful.util.spawn_with_shell("$HOME/bin/dex -a -e Awesome")
