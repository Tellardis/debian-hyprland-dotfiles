-- Hyprland 0.55 Lua config. Wiki: https://wiki.hypr.land/Configuring/Start/
-- Стартовая версия: минимум для первого входа. Основана на /usr/share/hypr/hyprland.lua

---- MONITOR ----
hl.monitor({
    output   = "",
    mode     = "1920x1080@180",
    position = "0x0",
    scale    = 1,
})

---- PROGRAMS ----
local terminal = "alacritty"
local menu     = "fuzzel"

---- ENV (NVIDIA, https://wiki.hypr.land/Nvidia/) ----
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("HYPRCURSOR_THEME", "breeze_cursors")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_STYLE_OVERRIDE", "adwaita-dark")

---- AUTOSTART ----
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/wallpaper-next loop 15")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user reset-failed hyprpolkitagent; systemctl --user start hyprpolkitagent")
end)

---- LOOK ----
hl.config({
    general = {
        gaps_in = 6, gaps_out = 12, border_size = 2,
        col = {
            active_border   = { colors = {"rgba(89b4faee)", "rgba(cba6f7ee)"}, angle = 45 },
            inactive_border = "rgba(45475aaa)",
        },
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        inactive_opacity = 0.96,
        shadow = { enabled = true, range = 16, render_power = 3, color = "rgba(11111bee)" },
        blur = { enabled = true, size = 6, passes = 2, vibrancy = 0.15 },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true, default_split_ratio = 1.33 },
    misc = { force_default_wallpaper = 0, disable_hyprland_logo = true },
    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = 0,
    },
})

---- ANIMATIONS ----
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},   {0.32, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},   {0.1, 1}  } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},  {0.75, 1} } })
hl.animation({ leaf = "windows",    enabled = true, speed = 4,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4,   bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2,   bezier = "quick",        style = "popin 90%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3,   bezier = "quick" })
hl.animation({ leaf = "border",     enabled = true, speed = 5,   bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3,   bezier = "easeOutQuint", style = "slide" })

---- KEYBINDS ----
local mainMod = "SUPER"
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
-- Фокус без стрелок (клавиатура 60%): Super + H/J/K/L (vim)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Скриншоты: Print = область в буфер + файл, Shift+Print = весь экран в файл
hl.bind("Print", hl.dsp.exec_cmd("sh -c 'f=$HOME/Pictures/Screenshots/$(date +%F_%H-%M-%S).png; grim -g \"$(slurp)\" \"$f\" && wl-copy < \"$f\"'"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("sh -c 'grim $HOME/Pictures/Screenshots/$(date +%F_%H-%M-%S).png'"))

-- Громкость (PipeWire)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/audio-toggle"))
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/wallpaper-next"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a -n -f hex"))

-- Перенос окна на соседний монитор
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ monitor = "r" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Изменение пропорции деления окон (dwindle): Super+Alt+H / L
hl.bind(mainMod .. " + ALT + H", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.layout("splitratio +0.1"), { repeating = true })
