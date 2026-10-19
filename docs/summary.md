# Итоговая сводка: Hyprland на Debian 13.7 (RTX 4070)

Hyprland 0.55.2 из trixie-backports, драйвер NVIDIA из репозитория NVIDIA, конфиг на Lua. Запасной вход: пункт GRUB «Debian GNOME» (проверен, работает).

## Что сделано

| Этап | Результат | Скрипт / файл | Откат |
|---|---|---|---|
| 0. Диагностика и бэкап | Снимок системы | diag.sh, diag.txt, 01-backup-and-simulate.sh, backup-20261019-170336/ | восстановить файлы из backup-*/ |
| 1. Репозиторий NVIDIA | cuda-keyring, nvidia-open | 02-add-nvidia-repo.sh, 03-install-driver.sh, 04-fix-595.sh, 05-upgrade.sh | dpkg-selections-before-upgrade.txt, backup-*/dpkg-selections.txt |
| 2. Backports | Только явные пакеты через -t trixie-backports | 06-backports.sh | убрать строку backports из /etc/apt/sources.list.d, apt update |
| 3. Hyprland | hyprland, hypridle, hyprlock, hyprpaper, portal, polkit-agent | 07-install-hyprland.sh | dpkg-selections-before-hyprland.txt |
| 4. Инструменты | waybar, alacritty, nvim и др. | 08-install-tools.sh | dpkg-selections-before-tools.txt |
| 5. Конфиг | ~/.config/hypr/hyprland.lua, Super+WASD/HJKL, столы 1-10 | cheatsheet.md, hypr.copy, hyprland.lua.copy | hyprland.lua.bak-before-* (по этапам) |
| 6. GRUB | Два пункта: Hyprland и Debian GNOME | 09-grub-two-entries.sh | sudo bash 09-rollback.sh |
| 7. Косметика | waybar, окна, обои, курсор, тёмная тема | cosmetics.md, 10-qt-cursor.sh | см. cosmetics.md, sudo bash 10-rollback.sh |
| 8. hypridle | Блокировка 10 мин, гашение экрана 15 мин | ~/.config/hypr/hypridle.conf | не менялся |
| 9. Сон выключен | sleep/suspend/hibernate/hybrid-sleep замаскированы | cosmetics.md | `sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target` |
| 10. Alacritty | Ctrl+Shift+C/V работают и на русской раскладке (с / м) | ~/.config/alacritty/alacritty.toml | alacritty.toml.bak-before-copy |
| 11. Звук | Переключение наушники/колонки: Super+F9, ПКМ по звуку в waybar | ~/.local/bin/audio-toggle | hyprland.lua.bak-before-audio, waybar-config.jsonc.bak-before-audio, rm ~/.local/bin/audio-toggle |
| 12. Обои по таймеру | Смена каждые 15 мин, Super+F10 вручную | ~/.local/bin/wallpaper-next | hyprland.lua.bak-before-wallpaper, hyprpaper.conf.bak-before-cosmetic |
| 13. Уведомления | mako: таймаут 3 с, цвета Catppuccin | ~/.config/mako/config | rm ~/.config/mako/config; makoctl reload |
| 14. Утилиты hypr | hyprshutdown (Super+M), hyprsunset (тёплый свет с 21:00), hyprpicker (Super+Shift+C) | 11-ecosystem.sh, ~/.config/hypr/hyprsunset.conf | sudo bash 11-rollback.sh, hyprland.lua.bak-before-ecosystem |
| 15. Старые ядра | Удалены 96/100/101, остались 107 и 113 | 12-clean-kernels.sh | dpkg-selections-before-kernels.txt (ядра ставятся через apt) |
| 16. Markdown в nvim | Рендер в буфере и предпросмотр (extra lang.markdown), плавный скролл отключён | lazyvim.json, ~/.config/nvim/lua/plugins/noscroll.lua | lazyvim.json.bak-before-markdown, rm noscroll.lua, :Lazy clean |
| 17. Пропорции окон | Новое окно 2/3 на 1/3, Super+Alt+H/L подгоняют | ~/.config/hypr/hyprland.lua, cheatsheet.html | hyprland.lua.bak-before-split |
| 18. Экран входа | greetd + tuigreet на tty2 только для пункта GRUB «Hyprland» (цель hypr-login.target), имя запоминается; GDM остаётся для «Debian GNOME»; предупреждения ядра не пишутся на экран; палитра Catppuccin и шрифт Terminus 32x16 (15-greeter-style.sh) | 13-greetd.sh, 14-quiet-console.sh, 15-greeter-style.sh, /etc/greetd/config.toml | sudo bash 13-rollback.sh; sudo rm /etc/sysctl.d/20-quiet-console.conf; sudo bash 15-rollback.sh |

## Бэкапы конфигов (в ~/Hyprland)

- hyprland.lua.bak-before-autostart, -monitor, -polkitfix, -vim, -wasd, -windows, -qtcursor
- profile.bak-before-grub, profile.bak-before-hypr
- waybar-config.jsonc.bak-before-cosmetic, waybar-style.css.bak-before-cosmetic
- hyprpaper.conf.bak-before-cosmetic
- alacritty.toml.bak-before-copy
- hyprland.lua.bak-before-audio, -wallpaper, -ecosystem, -split; lazyvim.json.bak-before-markdown; waybar-config.jsonc.bak-before-audio
- grub-backup-20261019-192822/ (default-grub, grub.cfg, grub.d)
- greetd-config.toml.bak-before-style
- greetd-backup-*/ (default-grub, grub.cfg, display-manager-link.txt), dpkg-selections-before-greetd.txt

## Полный откат к GNOME-only

1. `sudo bash ~/Hyprland/09-rollback.sh` (вернуть GRUB)
2. `sudo bash ~/Hyprland/10-rollback.sh` (пакеты косметики)
3. Пакеты Hyprland: по dpkg-selections-before-hyprland.txt, затем `apt autoremove`
4. Входить через GDM в GNOME как раньше.

## Не проверено / на будущее

- Включение экрана мышью после реального простоя 15 минут (принудительное dpms on работает).
- Бинды Super+Ctrl+H/L (перенос окна на другой монитор): монитор один.
- Возможно позже: uwsm. На tty1 остаётся запасной логин (Ctrl+Alt+F1), на tty3 тоже запускается Hyprland.
- Урок: первый запуск greetd на vt=1 дрался с getty@tty1 (agetty читал клавиши greeter-а), поэтому vt=2.
