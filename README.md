# Hyprland на Debian 13 (trixie): моя настройка

Конфиги и скрипты, чтобы после переустановки системы не настраивать всё заново.

Проверено на: Debian 13.7, Hyprland 0.55.2 (конфиг на Lua) из trixie-backports, NVIDIA RTX 4070 (драйвер `nvidia-open` ветки 595), монитор 1920x1080@180 Гц.

## Что внутри

| Путь | Назначение |
|---|---|
| `config/hypr` | Hyprland (`hyprland.lua`), hypridle, hyprlock, hyprpaper, hyprsunset |
| `config/waybar`, `config/mako`, `config/alacritty` | панель, уведомления, терминал (тема Catppuccin Mocha) |
| `config/nvim` | LazyVim с рендером Markdown |
| `docs/apps.md` | список приложений, которые ставятся вручную |
| `bin/` | `hypr` (запуск из TTY), `audio-toggle` (наушники/колонки), `wallpaper-next` (смена обоев) |
| `system/` | экран входа greetd + tuigreet, GRUB-пункт «Debian GNOME», тихая консоль, параметры NVIDIA |
| `home/profile-snippet.sh` | автозапуск Hyprland на tty3 (добавляется в `~/.profile`) |
| `docs/` | `summary.md` (что и зачем делалось), `cheatsheet.md/.html` (горячие клавиши), `cosmetics.md` |

## Установка на чистый Debian 13

Стадии запускаются по одной, в таком порядке:

```bash
sudo ./install.sh packages   # backports + Hyprland и утилиты
sudo ./install.sh nvidia     # драйвер NVIDIA (спросит подтверждение), затем reboot
./install.sh dotfiles        # конфиги в ~/.config, скрипты в ~/.local/bin (старые конфиги копируются в ~/.config-backup-*)
sudo ./install.sh login      # экран входа и GRUB; затем reboot
sudo ./install.sh plymouth   # необязательно: заставка загрузки; затем reboot
```

После перезагрузки в меню GRUB два пункта: **Hyprland** (с экраном входа tuigreet) и **Debian GNOME** (GDM, запасной вход).

Отдельно:
- Neovim ставится из архива с GitHub в `~/.local/opt`, симлинк в `~/.local/bin/nvim` (в Debian пакет старый). Для LazyVim нужны `git`, `ripgrep`, `fd-find`, `tree-sitter-cli`.
- Обои в репозиторий не входят. Положите картинки в `~/Pictures/Wallpapers`; `wallpaper-next` меняет их каждые 15 минут.
- В `hyprland.lua` указаны раскладки и монитор (`DP-1`, 180 Гц); под своё железо поправьте.

## Безопасность и откат

- Установка NVIDIA удаляет драйвер Debian (`purge`), поэтому перед ней убедитесь, что есть запасной способ входа.
- `login` меняет `/etc/default/grub` (бэкап в `/root/hypr-setup-backup-*`) и маскирует sleep/suspend/hibernate.
- `plymouth` добавляет `splash` в GRUB и модули nvidia в initramfs (бэкап в `/root/hypr-setup-backup-*`); нужна после `nvidia`.
- Подробности и команды отката по каждому этапу: `docs/summary.md`.
- Экран входа запускается только из пункта GRUB «Hyprland»; на tty1 остаётся обычный текстовый вход (Ctrl+Alt+F1).

## Что не входит

Секреты, ключи и данные приложений (Bitwarden, браузеры, мессенджеры), обои, настройки Steam/игр.
