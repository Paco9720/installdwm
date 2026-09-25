#!/bin/sh

export _JAVA_AWT_WM_NONREPARENTING=1
export GDK_BACKEND=x11
export GTK_THEME=Adwaita-dark
export QT_QPA_PLATFORMTHEME=qt6ct
export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_DESKTOP=dwm
export XDG_SESSION_TYPE=x11

xsetroot -cursor_name left_ptr

# pasar variables X11 a systemd user
systemctl --user import-environment \
  DISPLAY \
  XAUTHORITY \
  DBUS_SESSION_BUS_ADDRESS \
  XDG_CURRENT_DESKTOP \
  XDG_SESSION_DESKTOP \
  XDG_SESSION_TYPE

dbus-update-activation-environment --systemd \
  DISPLAY \
  XAUTHORITY \
  DBUS_SESSION_BUS_ADDRESS \
  XDG_CURRENT_DESKTOP \
  XDG_SESSION_DESKTOP \
  XDG_SESSION_TYPE

while true; do
    xsetroot -name "$(date '+%a %d %b %H:%M')"
    sleep 30
done &

# reiniciar portal ya con DISPLAY
systemctl --user restart xdg-desktop-portal
systemctl --user restart xdg-desktop-portal-gtk

# wallpaper
feh --bg-fill /mnt/sda1/pictures/debianfondo.png &

# servicios
sxhkd &
dunst &
picom --config ~/.config/picom/picom.conf &
numlockx on &

# file manager daemon
thunar --daemon &

exec dwm
