# Hyperland System: start Hyprland when a normal user logs in on tty1.
# Create ~/.no-autostart to disable.
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -z "${DISPLAY:-}" ] \
   && [ "$(tty)" = "/dev/tty1" ] && [ "$(id -u)" -ne 0 ] \
   && [ ! -e "$HOME/.no-autostart" ]; then
    if command -v start-hyprland >/dev/null 2>&1; then
        start-hyprland
    else
        Hyprland
    fi
    echo "Hyprland exited. Type 'Hyprland' to start it again."
fi
