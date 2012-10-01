tomac() {
    xmodmap ~/tap/etc/keymaps/dvorak_apple.kbd
}

tohome() {
    xrandr --output HDMI1 --off
    sleep 1
    xrandr --fb 1366x768
    sleep 1
    xrandr --output LVDS1 --auto
    sleep 1
    xrandr --output VGA1 --off 
    #xmodmap ~/tap/etc/keymaps/dvorak_laptop.kbd
    smount -u array
}

towork() {
    xrandr --output VGA1 --auto
    sleep 1
    xrandr --output LVDS1 --off
    sleep 1
    xrandr --output HDMI1 --auto --left-of VGA1
    #xmodmap ~/tap/etc/keymaps/dvorak_apple.kbd
}

toclass() {
    xrandr --fb 1024x768
    sleep 1
    xrandr --output VGA1 --same-as LVDS1
    sleep 1
}
