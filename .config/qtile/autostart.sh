#!/usr/bin/env bash 

### AUTOSTART PROGRAMS ###
copyq & 
#flameshot & 
lxsession & 
mpv --no-video ~/Music/startup.mp3 & 
nm-applet & 
picom --daemon & 
redshift &
volumeicon & 
xfce4-power-manager &

### UNCOMMENT ONLY ONE OF THE TWO OPTIONS! ###
#1.Restore the Last Wallpaper
nitrogen --restore & 
#2.Get a Random Wallpaper
#nitrogen --set-zoom-fill --random ~/wallpapers & 
