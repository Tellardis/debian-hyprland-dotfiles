# Автозапуск Hyprland: tty3 всегда; tty1 только если графическая цель (GDM) не запущена
# (откат: удалить этот блок)
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && command -v hypr >/dev/null 2>&1; then
    if [ "${XDG_VTNR:-}" = "3" ] || { [ "${XDG_VTNR:-}" = "1" ] && ! systemctl is-active --quiet graphical.target; }; then
        exec hypr
    fi
fi
