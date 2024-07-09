##### IMPORTS #####
import os
import subprocess
from libqtile import bar, extension, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen
from libqtile.lazy import lazy
# Make sure 'qtile-extras' is installed or this config will not work.
from qtile_extras import widget
from qtile_extras.widget.decorations import BorderDecoration
#from qtile_extras.widget import StatusNotifier
import colors

##### VARIABLES #####
mod = "mod4"              # Sets mod key to SUPER/WINDOWS
ctrl = "control"		  # Defines control key as ctrl
myTerm = "alacritty"      # My terminal of choice
myBrowser = "librewolf"   # My browser of choice
myEditor = "geany"		  # My text editor of choice

##### CUSTOM FUNCTIONS #####
# Allows you to input a name when adding treetab section.
@lazy.layout.function
def add_treetab_section(layout):
    prompt = qtile.widgets_map["prompt"]
    prompt.start_input("Section name: ", layout.cmd_add_section)

# A function for hide/show all the windows in a group
@lazy.function
def minimize_all(qtile):
    for win in qtile.current_group.windows:
        if hasattr(win, "toggle_minimize"):
            win.toggle_minimize()
           
# A function for toggling between MAX and MONADTALL layouts
@lazy.function
def maximize_by_switching_layout(qtile):
    current_layout_name = qtile.current_group.layout.name
    if current_layout_name == 'monadtall':
        qtile.current_group.layout = 'max'
    elif current_layout_name == 'max':
        qtile.current_group.layout = 'monadtall'
        
##### KEYBINDINGS #####       
keys = [
    # The essentials
    Key([mod], "Return", lazy.spawn(myTerm), desc='Terminal'),
    Key([mod,  "shift"], "Return", lazy.spawn("dmenu_run -l 10 -p ' Run: '"), desc='Run Launcher'),
    Key([mod], "g", lazy.spawn(myEditor), desc='Text Editor'),
    Key([mod], "b", lazy.spawn(myBrowser), desc='Web Browser'),
    Key([mod], "c", lazy.spawn(myEditor + " /home/aston/.config/qtile/config.py"), desc='Open My Qtile Config'),
    
    # Utilities
    Key([mod,  "shift"], "f", lazy.spawn("pcmanfm"), desc='File Manager'),
    Key([mod], "r", lazy.spawn(myTerm + " -e ranger"), desc='Ranger File Manager'),
    Key([mod,  "shift"], "v", lazy.spawn("virt-manager"), desc='Virt-Manager'),
    Key([mod,  "shift"], "t", lazy.spawn("thunderbird"), desc='Email Client'),
    
    # Brightness Control
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%"), desc='Increase brightness by 10%'),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-"), desc='Decrease brightness by 10%'),
    
    # Audio Control & Utilities
    Key([ctrl], "F3", lazy.spawn("amixer set Master 5%+"), desc='Increase volume'),
    Key([ctrl], "F2", lazy.spawn("amixer set Master 5%-"), desc='Decrease volume'),
    Key([ctrl], "F4", lazy.spawn("amixer set Master toggle"), desc='Mute volume'),
    Key([mod],  "v",  lazy.spawn("pavucontrol"), desc='Volume Control'),
    
    # Qtile 
    Key([mod], "Tab", lazy.next_layout(), desc='Toggle between layouts'),
    Key([mod], 	 "q", 	lazy.window.kill(), desc='Kill focused window'),
    Key([mod,  "shift"], "r", lazy.reload_config(), desc='Reload the config'),
    Key([mod,  "shift"], "q", lazy.spawn("dm-logout"), desc='Logout menu'),
    
    # Switch between windows
    # Some layouts like 'monadtall' only need to use j/k to move
    # through the stack, but other layouts like 'columns' will
    # require all four directions h/j/k/l to move around.
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h",
        lazy.layout.shuffle_left(),
        lazy.layout.move_left().when(layout=["treetab"]),
        desc="Move window to the left/move tab left in treetab"),

    Key([mod, "shift"], "l",
        lazy.layout.shuffle_right(),
        lazy.layout.move_right().when(layout=["treetab"]),
        desc="Move window to the right/move tab right in treetab"),

    Key([mod, "shift"], "j",
        lazy.layout.shuffle_down(),
        lazy.layout.section_down().when(layout=["treetab"]),
        desc="Move window down/move down a section in treetab"
    ),
    Key([mod, "shift"], "k",
        lazy.layout.shuffle_up(),
        lazy.layout.section_up().when(layout=["treetab"]),
        desc="Move window downup/move up a section in treetab"
    ),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "space", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),

    # Treetab prompt
    Key([mod, "shift"], "a", add_treetab_section, desc='Prompt to add new section in treetab'),

    # Grow/shrink windows left/right. 
    # This is mainly for the 'monadtall' and 'monadwide' layouts
    # although it does also work in the 'bsp' and 'columns' layouts.
    Key([mod], "equal",
        lazy.layout.grow_left().when(layout=["bsp", "columns"]),
        lazy.layout.grow().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),
    Key([mod], "minus",
        lazy.layout.grow_right().when(layout=["bsp", "columns"]),
        lazy.layout.shrink().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),

    # Grow windows up, down, left, right.  Only works in certain layouts.
    # Works in 'bsp' and 'columns' layout.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "m", lazy.layout.maximize(), desc='Toggle between min and max sizes'),
    Key([mod], "t", lazy.window.toggle_floating(), desc='toggle floating'),
    Key([mod], "f", maximize_by_switching_layout(), lazy.window.toggle_fullscreen(), desc='toggle fullscreen'),
    Key([mod, "shift"], "m", minimize_all(), desc="Toggle hide/show all windows on current group"),

    # Switch focus of monitors
    Key([mod], "period", lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod], "comma", lazy.prev_screen(), desc='Move focus to prev monitor'),
    
    # Dmenu/rofi scripts launched using the key chord SUPER+p followed by 'key'
    KeyChord([mod], "p", [
        Key([], "h", lazy.spawn("dm-hub"), desc='List all dmscripts'),
        #Key([], "a", lazy.spawn("dm-sounds"), desc='Choose ambient sound'),
        Key([], "b", lazy.spawn("/home/aston/ro-scripts/wallpaper.sh"), desc='Set background'),
        #Key([], "c", lazy.spawn("dtos-colorscheme"), desc='Choose color scheme'),
        Key([], "e", lazy.spawn("dm-confedit"), desc='Choose a config file to edit'),
        #Key([], "i", lazy.spawn("dm-maim"), desc='Take a screenshot'),
        Key([], "k", lazy.spawn("dm-kill"), desc='Kill processes '),
        Key([], "m", lazy.spawn("dm-man"), desc='View manpages'),
        #Key([], "n", lazy.spawn("dm-note"), desc='Store and copy notes'),
        Key([], "o", lazy.spawn("dm-bookman"), desc='Browser bookmarks'),
        #Key([], "p", lazy.spawn("rofi-pass"), desc='Logout menu'),
        Key([], "q", lazy.spawn("dm-logout"), desc='Logout menu'),
        #Key([], "r", lazy.spawn("dm-radio"), desc='Listen to online radio'),
        Key([], "s", lazy.spawn("dm-websearch"), desc='Search various engines'),
        Key([], "t", lazy.spawn("dm-translate"), desc='Translate text')
    ])
]

##### GROUPS #####
groups = []
group_names = ["1", "2", "3", "4", "5", "6",]

group_labels = ["", "", "", "", "", "󰝚",]
#group_labels = ["1", "2", "3", "4", "5", "6",]

group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall"]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))
 
for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=False),
                desc="Move focused window to group {}".format(i.name),
            ),
        ]
    )

##### COLORSCHEME #####
colors = colors.DoomOne

##### DEFAULT SETTINGS FOR ALL LAYOUTS #####
layout_theme = {"border_width": 2,
                "margin": 8,
                "border_focus": colors[8],
                "border_normal": colors[0]
                }

##### LAYOUTS #####
layouts = [
    #layout.Bsp(**layout_theme),
    #layout.Floating(**layout_theme)
    #layout.RatioTile(**layout_theme),
    #layout.VerticalTile(**layout_theme),
    #layout.Matrix(**layout_theme),
    layout.MonadTall(**layout_theme),
    #layout.MonadWide(**layout_theme),
    layout.Tile(
         shift_windows=True,
         border_width = 0,
         margin = 0,
         ratio = 0.335,
         ),
    layout.Max(
         border_width = 0,
         margin = 0,
         ),
    #layout.Stack(**layout_theme, num_stacks=2),
    #layout.Columns(**layout_theme),
    #layout.TreeTab(
    #     font = "Ubuntu Bold",
    #     fontsize = 11,
    #     border_width = 0,
    #     bg_color = colors[0],
    #     active_bg = colors[8],
    #     active_fg = colors[2],
    #     inactive_bg = colors[1],
    #     inactive_fg = colors[0],
    #     padding_left = 8,
    #     padding_x = 8,
    #     padding_y = 6,
    #     sections = ["ONE", "TWO", "THREE"],
    #     section_fontsize = 10,
    #     section_fg = colors[7],
    #     section_top = 15,
    #     section_bottom = 15,
    #     level_shift = 8,
    #     vspace = 3,
    #     panel_width = 240
    #     ),
    #layout.Zoomy(**layout_theme),
]

##### DEFINES A SHORTER UPTIME OUTPUT #####
def shorten_uptime(uptime_str):
    parts = uptime_str.split(', ')
    short_parts = []

    for part in parts:
        if part.endswith(' hours'):
            short_parts.append(part.replace(' hours', 'h'))
        elif part.endswith(' hour'):
            short_parts.append(part.replace(' hour', 'h'))
        elif part.endswith(' minutes'):
            short_parts.append(part.replace(' minutes', 'm'))
        elif part.endswith(' minute'):
            short_parts.append(part.replace(' minute', 'm'))
        else:
            short_parts.append(part)  

    return ', '.join(short_parts)

widget_defaults = dict(
    font="Ubuntu Bold",
    fontsize = 14,
    padding = 0,
    background=colors[0]
)

extension_defaults = widget_defaults.copy()

##### WIDGETS #####
def init_widgets_list():
    widgets_list = [
        widget.Spacer(length = 8),
        widget.Image(
                 filename = "~/.config/qtile/icons/python-white.png",
                 scale = "False",
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm)},
                 ),
        widget.GroupBox(
                 fontsize = 14,
                 margin_y = 3,
                 margin_x = 3,
                 padding_y = 5,
                 padding_x = 5,
                 borderwidth = 3,
                 active = colors[8],
                 inactive = colors[1],
                 rounded = False,
                 highlight_color = colors[2],
                 highlight_method = "text",
                 this_current_screen_border = colors[7],
                 this_screen_border = colors [4],
                 other_current_screen_border = colors[7],
                 other_screen_border = colors[4],
                 ),
        widget.Sep(
                 foreground = colors[1],
                 padding = 10,
                 size_percent = 50
                 ),
        widget.CurrentLayoutIcon(
                 foreground = colors[1],
                 padding = 4,
                 scale = 0.6
                 ),
        widget.CurrentLayout(
                 foreground = colors[1],
                 padding = 5
                 ),
        widget.Sep(
                 foreground = colors[1],
                 padding = 8,
                 size_percent = 50
                 ),
        widget.WindowName(
                 foreground = colors[6],
                 padding = 3,
                 max_chars = 40
                 ),
        widget.GenPollText(
                 update_interval = 300,
                 func = lambda: subprocess.check_output("printf $(uname -r)", shell=True, text=True),
                 foreground = colors[3],
                 fmt = '󰋑   {}',
                 decorations=[
                     BorderDecoration(
                         colour = colors[3],
                         border_width = [0, 0, 2, 0],
                     )
                 ],
                 ),
        widget.Spacer(length = 8),
        widget.CPU(
                 format = '   Cpu: {load_percent}%',
                 foreground = colors[4],
                 decorations=[
                     BorderDecoration(
                         colour = colors[4],
                         border_width = [0, 0, 2, 0],
                     )
                 ],
                 ),
        widget.Spacer(length = 8),
        widget.Memory(
                 foreground = colors[8],
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e htop')},
                 #format = '{MemUsed: .0f}{mm} ({MemPercent:.0f}%)',
                 format = '{MemUsed: .0f}{mm}',
                 fmt = '🖥  Mem: {}',
                 decorations=[
                     BorderDecoration(
                         colour = colors[8],
                         border_width = [0, 0, 2, 0],
                     )
                 ],
                 ),
        widget.Spacer(length = 8),
        widget.GenPollText(
                 update_interval = 60,
                 func=lambda: shorten_uptime(subprocess.check_output(["uptime", "-p"]).decode().strip()[3:]),
                 foreground = colors[7],
                 fmt = '   Uptime:  {}',
                 decorations=[
                     BorderDecoration(
                         colour = colors[7],
                         border_width = [0, 0, 2, 0],
                     )
                 ],
                 ),
        widget.Spacer(length = 8),
        widget.CheckUpdates(
                 update_interval=1800,  
                 distro="Arch_checkupdates", 
                 display_format='   {updates} Updates',
                 no_update_string='   0 Updates',
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e sudo pacman -Syu')},
                 colour_have_updates=colors[3],
                 colour_no_updates=colors[3],
                 decorations=[
                     BorderDecoration(
                         colour=colors[3],
                         border_width=[0, 0, 2, 0],
                      )
                   ],
                   ),
        widget.Spacer(length = 8),
        widget.DF(
                 update_interval = 60,
                 foreground = colors[5],
                 partition = '/',
                 #format = '[{p}] {uf}{m} ({r:.0f}%)',
                 format = '{uf}{m} free',
                 fmt = '🖴  Disk: {}',
                 visible_on_warn = False,
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('pcmanfm')},
                 decorations=[
                     BorderDecoration(
                         colour = colors[5],
                         border_width = [0, 0, 2, 0],
                     )
                 ],
                 ),
        widget.Spacer(length = 8),
        widget.Volume(
                 foreground = colors[7],
                 fmt = '🕫  Vol: {}',
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('pavucontrol')},
                 decorations=[
                     BorderDecoration(
                         colour = colors[7],
                         border_width = [0, 0, 2, 0],
                     )
                 ],
                 ),
        widget.Spacer(length = 8),
        widget.Battery(
				 foreground = colors[4],
				 format = '󰂄  Bat:  {percent:2.0%}',
				 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('xfce4-power-manager-settings')},
				 decorations=[
					 BorderDecoration(
                        colour = colors[4],
                        border_width = [0, 0, 2, 0],
					 )
				 ],
			     ),
        widget.Spacer(length = 8),
        widget.Clock(
                 foreground = colors[8],
                 format = "⏱  %a, %b %d - %I:%M",
                 decorations=[
                     BorderDecoration(
                         colour = colors[8],
                         border_width = [0, 0, 2, 0],
                     )
                 ],
                 ),
        widget.Spacer(length = 8),
        widget.Systray(padding = 3),
        widget.Spacer(length = 8),
	    ]
    return widgets_list

##### SCREENS #####
def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    return widgets_screen1 

# All other monitors' bars will display everything but widgets 26 (systray) and 27 (spacer).
def init_widgets_screen2():
    widgets_screen2 = init_widgets_list()
    del widgets_screen2[26:28]
    return widgets_screen2

# For adding transparency to your bar, add (background="#00000000") to the "Screen" line(s)
# For ex: Screen(top=bar.Bar(widgets=init_widgets_screen1(), background="#00000000", size=26)),
def init_screens():
    return [Screen(top=bar.Bar(widgets=init_widgets_screen1(), size=26)),
		    Screen(top=bar.Bar(widgets=init_widgets_screen2(), size=26)),
		    Screen(top=bar.Bar(widgets=init_widgets_screen2(), size=26))]

if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    widgets_screen2 = init_widgets_screen2()

##### SOME IMPORTANT FUNCTIONS #####
def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)

def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)

def window_to_previous_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group)

def window_to_next_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group)

def switch_screens(qtile):
    i = qtile.screens.index(qtile.current_screen)
    group = qtile.screens[i - 1].group
    qtile.current_screen.set_group(group)

##### DRAG FLOATING LAYOUTS #####
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

##### WINDOW RULES #####
dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=colors[8],
    border_width=2,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),   # gitk
        Match(wm_class="dialog"),         # dialog boxes
        Match(wm_class="download"),       # downloads
        Match(wm_class="error"),          # error msgs
        Match(wm_class="file_progress"),  # file progress boxes
        Match(wm_class='kdenlive'),       # kdenlive
        Match(wm_class="makebranch"),     # gitk
        Match(wm_class="maketag"),        # gitk
        Match(wm_class="notification"),   # notifications
        Match(wm_class="toolbar"),        # toolbars
        Match(wm_class="Yad"),            # yad boxes
        Match(title="branchdialog"),      # gitk
        Match(title='Qalculate!'),        # qalculate!-gtk
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

##### AUTOSTART PROGRAMS #####
@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])
    
##### JAVA APPS MIGHT NEED THIS #####
wmname = "LG3D"
