# Косметика: итог

| Что | Где | Бэкап (в ~/Hyprland) |
|---|---|---|
| Waybar: Nerd Font, иконки, блоки Catppuccin | ~/.config/waybar/config.jsonc, style.css | waybar-config.jsonc.bak-before-cosmetic, waybar-style.css.bak-before-cosmetic |
| Окна: рамка, скругление 10, тени, блюр, анимации | ~/.config/hypr/hyprland.lua (LOOK, ANIMATIONS) | hyprland.lua.bak-before-windows |
| Обои abstract-swirls.jpg | ~/.config/hypr/hyprpaper.conf, ~/Pictures/Wallpapers/ | hyprpaper.conf.bak-before-cosmetic |
| Курсор breeze_cursors, Qt через GTK (adwaita-dark) | hyprland.lua (hl.env), gsettings | hyprland.lua.bak-before-qtcursor, 10-rollback.sh |
| Тёмная GTK-тема Adwaita-dark | ~/.config/gtk-3.0/settings.ini, gtk-4.0/settings.ini, gsettings | (файлов раньше не было) |

## Откат
- Waybar: cp waybar-*.bak-before-cosmetic обратно в ~/.config/waybar/ (имена config.jsonc и style.css), затем pkill waybar; waybar &
- Окна/курсор/Qt: cp ~/Hyprland/hyprland.lua.bak-before-windows ~/.config/hypr/hyprland.lua; hyprctl reload (env-переменные: нужен перелогин)
- Обои: cp hyprpaper.conf.bak-before-cosmetic ~/.config/hypr/hyprpaper.conf; pkill hyprpaper; hyprpaper &
- Пакеты: sudo bash ~/Hyprland/10-rollback.sh
- GTK: rm ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

Смена обоев: правка строки path в hyprpaper.conf + перезапуск hyprpaper.

## Сон и гибернация (маскировка)
Выполнено: sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
Откат: sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
