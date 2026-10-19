#!/usr/bin/env bash
# Установка Hyprland на Debian 13 (trixie) по этому репозиторию.
# Стадии запускаются по одной, каждая безопасна к повторному запуску.
#   ./install.sh dotfiles        конфиги и скрипты пользователя (без sudo)
#   sudo ./install.sh packages   backports + пакеты Hyprland
#   sudo ./install.sh nvidia     драйвер NVIDIA из репозитория NVIDIA (с подтверждением)
#   sudo ./install.sh login      экран входа (greetd + tuigreet), GRUB, тихая консоль
set -euo pipefail
ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
NVIDIA_BRANCH="${NVIDIA_BRANCH:-595}"

need_root() { [ "$(id -u)" -eq 0 ] || { echo "Запустите через sudo"; exit 1; }; }

stage_dotfiles() {
  [ "$(id -u)" -ne 0 ] || { echo "Эту стадию запускайте без sudo"; exit 1; }
  local ts bak; ts="$(date +%Y%m%d-%H%M%S)"; bak="$HOME/.config-backup-$ts"
  mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots"
  for d in "$ROOT"/config/*/; do
    n="$(basename "$d")"
    if [ -e "$HOME/.config/$n" ]; then mkdir -p "$bak"; cp -a "$HOME/.config/$n" "$bak/"; fi
    mkdir -p "$HOME/.config/$n"
    cp -a "$d". "$HOME/.config/$n/"
  done
  [ ! -d "$bak" ] || echo "Старые конфиги сохранены в $bak"
  sed -i "s|@HOME@|$HOME|g" "$HOME/.config/hypr/hyprpaper.conf"
  sed -i "s|@HOME@|$HOME|g" "$HOME/.config/flameshot/flameshot.ini"
  install -m 755 "$ROOT"/bin/* "$HOME/.local/bin/"
  if ! grep -q 'Автозапуск Hyprland' "$HOME/.profile" 2>/dev/null; then
    { echo; cat "$ROOT/home/profile-snippet.sh"; } >> "$HOME/.profile"
  fi
  echo "Готово. Положите обои в ~/Pictures/Wallpapers и поправьте path в ~/.config/hypr/hyprpaper.conf"
}

stage_packages() {
  need_root
  echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" \
    > /etc/apt/sources.list.d/trixie-backports.list
  apt-get update
  apt-get install -y -t trixie-backports \
    hyprland hyprland-guiutils xdg-desktop-portal-hyprland xwayland \
    hyprpaper hypridle hyprlock hyprpolkitagent hyprshutdown hyprsunset hyprpicker \
    waybar mako-notifier fuzzel
  apt-get install -y alacritty grim slurp wl-clipboard pipewire-pulse wireplumber
  apt-get install -y git curl wget unzip ripgrep fd-find build-essential cmake ninja-build \
    fastfetch htop flameshot xdotool fonts-jetbrains-mono breeze-cursor-theme gnome-tweaks \
    adwaita-qt qt5-gtk-platformtheme qt6-gtk-platformtheme
  echo "Neovim (LazyVim) ставится отдельно, см. README."
}

stage_nvidia() {
  need_root
  local tmp; tmp="$(mktemp -d)"
  wget -O "$tmp/cuda-keyring.deb" \
    "https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/cuda-keyring_1.1-1_all.deb"
  dpkg -i "$tmp/cuda-keyring.deb"; rm -rf "$tmp"
  apt-get update
  apt-get install -y "nvidia-driver-pinning-$NVIDIA_BRANCH"
  apt-get update
  apt-get -s install nvidia-open | grep -E '^(Inst|Remv)' | cut -c1-140 | head -60 || true
  echo "Будет заменён драйвер Debian на nvidia-open ветки $NVIDIA_BRANCH (старые nvidia-пакеты удаляются)."
  read -r -p "Продолжить? Введите yes: " ans
  [ "$ans" = "yes" ] || { echo "Отменено."; exit 0; }
  systemctl stop gdm 2>/dev/null || true
  apt-get purge -y '*nvidia*' libcuda1 libnvcuvid1 glx-alternative-mesa glx-alternative-nvidia glx-diversions update-glx || true
  apt-get install -y nvidia-open
  install -m 644 "$ROOT"/system/modprobe.d/*.conf /etc/modprobe.d/
  update-initramfs -u
  dkms status || true
  echo "Перезагрузитесь: sudo reboot"
}

stage_login() {
  need_root
  local bak="/root/hypr-setup-backup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$bak"
  cp -a /etc/default/grub "$bak/" ; cp -a /boot/grub/grub.cfg "$bak/" 2>/dev/null || true
  echo "Бэкап GRUB: $bak"
  apt-get install -y greetd tuigreet
  systemctl disable greetd 2>/dev/null || true
  # display-manager остаётся прежним (gdm), greetd стартует только из hypr-login.target
  install -d -o _greetd -g _greetd /var/cache/tuigreet
  install -d /etc/greetd /etc/systemd/system/greetd.service.d
  sed "s|@HOME@|$USER_HOME|g" "$ROOT/system/greetd/config.toml" > /etc/greetd/config.toml
  install -m 644 "$ROOT/system/greetd/vtrgb" /etc/greetd/vtrgb
  install -m 644 "$ROOT/system/greetd.service.d/style.conf" /etc/systemd/system/greetd.service.d/style.conf
  install -m 644 "$ROOT/system/systemd/hypr-login.target" /etc/systemd/system/hypr-login.target
  install -m 644 "$ROOT/system/sysctl.d/20-quiet-console.conf" /etc/sysctl.d/20-quiet-console.conf
  sysctl --system >/dev/null
  install -m 755 "$ROOT/system/grub.d/12_gnome" /etc/grub.d/12_gnome
  sed -i 's/ systemd.unit=[^" ]*//' /etc/default/grub
  sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"|GRUB_CMDLINE_LINUX_DEFAULT="\1 systemd.unit=hypr-login.target"|' /etc/default/grub
  systemctl daemon-reload
  systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
  update-grub
  echo "Готово. В меню GRUB: пункт Hyprland (экран входа) и Debian GNOME (GDM, запасной)."
}

case "${1:-}" in
  dotfiles) stage_dotfiles ;;
  packages) stage_packages ;;
  nvidia)   stage_nvidia ;;
  login)    stage_login ;;
  *) sed -n '2,8p' "$0"; exit 1 ;;
esac
