# thinkpad-river

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue?logo=linux&logoColor=white)](https://kernel.org)
[![Wayland](https://img.shields.io/badge/Wayland-Native-brightgreen?logo=wayland&logoColor=white)](https://wayland.freedesktop.org)
[![Compositor: River](https://img.shields.io/badge/Compositor-River-orange)](https://codeberg.org/river/river)
[![Hardware: ThinkPad](https://img.shields.io/badge/Hardware-ThinkPad-red)](https://www.lenovo.com/thinkpad)
[![Kernel: 5.17+](https://img.shields.io/badge/Kernel-5.17%2B-informational?logo=linux&logoColor=white)](https://kernel.org)

A barebones Wayland rice for ThinkPads, built on [River](https://codeberg.org/river/river). No wallpaper, no compositor effects, no decorations — nothing that doesn't serve a direct purpose. Pure black everywhere, subpixel rendering disabled, optimized for OLED panels. Battery thresholds and thermal profiles are managed via [vantage](https://github.com/AdmiralBarbarossa/Minimal-vantage), a keyboard-driven TUI for ThinkPad ACPI controls. Keyboard-driven throughout with vim-style navigation.

![preview](screenshots/preview.png)

## Stack

| Role | Tool |
|---|---|
| Compositor | River |
| Status bar | Waybar |
| Terminal | Foot |
| Launcher | Fuzzel |
| Notifications | Mako |
| File manager | Yazi (custom theme: [thinkpad-red-oled](https://github.com/AdmiralBarbarossa/thinkpad-red-oled.yazi)) |
| PDF viewer | Zathura |
| Idle / lock | Swayidle + Waylock |
| Night light | Wlsunset |
| Hardware TUI | [Vantage](https://github.com/AdmiralBarbarossa/Minimal-vantage) |

## Requirements

- Linux kernel 5.17+ (battery threshold support)
- River (includes rivertile), Waybar, Foot, Fuzzel, Mako, Swayidle, Waylock
- Wlr-randr, Wlopm
- Grim, Slurp, Wl-clipboard, Swappy (screenshots)
- Brightnessctl, Pamixer, Wlsunset, Wob, libnotify (notify-send)
- Yazi, Zathura, Htop
- Qt6ct (Qt theming — required for Qt apps to respect the dark theme)
- JetBrainsMono Nerd Font
- `gum` (required by vantage)

## Installation

```bash
git clone --recurse-submodules https://github.com/AdmiralBarbarossa/thinkpad-river
cd thinkpad-river
./install.sh
```

The installer checks for missing dependencies, then prompts for your repo location, display output names, mode, scale, browser, keyboard layout, cursor size, and night light temperature. It generates `river/init.local` with your values, patches `swayidle/config` and the waybar configs (which are not shell scripts and cannot read `init.local` directly), and installs vantage.

After the installer finishes, fill in your input device identifiers:

```bash
riverctl list-inputs
```

Then edit `river/init.local` and set `KEYBOARD`, `TOUCHPAD`, and `TRACKPOINT` to the identifiers shown. Leave `TRACKPOINT` empty if your hardware has none.

Symlink the configs into `~/.config` (adjust the path if you cloned elsewhere):

```bash
RICE=~/thinkpad-river
ln -sf $RICE/river       ~/.config/river
ln -sf $RICE/waybar      ~/.config/waybar
ln -sf $RICE/foot        ~/.config/foot
ln -sf $RICE/fuzzel      ~/.config/fuzzel
ln -sf $RICE/mako        ~/.config/mako
ln -sf $RICE/swayidle    ~/.config/swayidle
ln -sf $RICE/yazi        ~/.config/yazi
ln -sf $RICE/zathura     ~/.config/zathura
ln -sf $RICE/htop        ~/.config/htop
ln -sf $RICE/fontconfig  ~/.config/fontconfig
```

> `fontconfig` disables subpixel hinting and LCD filtering — optimised for OLED panels where subpixel rendering causes colour fringing.

Create the River session service (required for `graphical-session.target` and xdg-desktop-portal):

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/river-session.service << 'EOF'
[Unit]
Description=River Wayland compositor session
BindsTo=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target

[Service]
Type=simple
ExecStart=/bin/true
RemainAfterExit=yes
EOF
```

Enable mako's systemd user service:

```bash
systemctl --user enable mako.service
```

## Machine-local config

All machine-specific settings live in `river/init.local`, which is gitignored. The installer generates this file from your answers. If you are setting up manually, copy the example and fill in your values:

```bash
cp river/init.local.example river/init.local
```

`init.local` controls:

| Variable | Description |
|---|---|
| `BROWSER` | Browser command (e.g. `firefox`, `librewolf`) |
| `KBLAYOUT` | Keyboard layout (e.g. `us`, `de`, `fr`) |
| `XCURSOR_SIZE` | Cursor size — scale to match your display DPI |
| `INT` / `EXT` | Internal and external output names (`wlr-randr` to list) |
| `INTMODE` / `INTSCALE` | Internal display mode and fractional scale |
| `KEYBOARD` / `TOUCHPAD` / `TRACKPOINT` | Input device identifiers (`riverctl list-inputs` to find) |
| `WLSUNSET_TEMP` | Night light color temperature in Kelvin (default: `3200` — lower is warmer) |
| `LIBVA_DRIVER_NAME` / `LIBVA_DRIVERS_PATH` / `MOZ_SANDBOX_READ_PATH` | VA-API driver path overrides — only needed if your distro installs the driver outside the default search path |

`display-cycle.sh` also reads `init.local` directly, so display variables only need to be set in one place.

## Hardware video decoding

Firefox and Librewolf support VA-API hardware video decoding on Wayland. On most distros the driver is in the default search path and no extra config is needed. On Fedora with RPM Fusion nonfree the driver lives outside the default path — uncomment and set the `LIBVA_*` variables in `river/init.local`:

```bash
LIBVA_DRIVER_NAME="iHD"
LIBVA_DRIVERS_PATH="/usr/lib64/dri-nonfree"
MOZ_SANDBOX_READ_PATH="/usr/lib64/dri-nonfree"
```

Then enable hardware decoding in the browser by adding a `user.js` to your profile:

```javascript
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.compositor", true);
user_pref("gfx.webrender.compositor.force-enabled", true);
```

Verify it worked at `about:support` → Media — H264, VP9, and AV1 should show Hardware Decoding as Supported.

## River Defaults

River ships with no keybindings or layout out of the box — everything must be configured explicitly. This rice wires up River's built-in features but does not modify their underlying behaviour:

- **Tiling** — rivertile, zero view padding and zero outer padding (no gaps)
- **Tags** — 9 tags configured, tag 1 focused on startup
- **Floating** — native float toggle, move, resize, and snap
- **Passthrough mode** — one passthrough mode declared for VM use
- **Locked mode** — volume and brightness keys remain active on the lock screen

**Explicitly set:**

- Border: 1px, focused `#707070`, unfocused `#000000`
- Key repeat: 300ms delay, 50 repeats/second
- Layout: rivertile with `-view-padding 0 -outer-padding 0`
- Background: `#000000`
- `GTK_CSD=0` — removes title bars from GTK apps globally

## Input Devices

Input device identifiers are hardware-specific and set in `river/init.local`. To find yours:

```bash
riverctl list-inputs
```

Set `KEYBOARD`, `TOUCHPAD`, and `TRACKPOINT` in `river/init.local` to the identifiers shown. Leave `TRACKPOINT` empty if your hardware has none — the config guards against it.

**Touchpad:** acceleration 0.6 adaptive, natural scroll, tap-to-click, clickfinger

**TrackPoint:** acceleration 0.8 adaptive

**Keyboard layout:** set via `KBLAYOUT` in `river/init.local`

## Keybindings

### Applications
| Key | Action |
|---|---|
| `Super + Shift + Return` | Terminal (foot) |
| `Super + D` | Launcher (fuzzel) |
| `Super + W` | Browser |
| `Super + E` | File manager (yazi) |
| `XF86Assistant` | File manager (yazi) — ThinkPad AI key |
| `Super + I` | Toggle idle inhibit (prevents auto-lock/suspend) |
| `Super + N` | Toggle night light (temperature set by `WLSUNSET_TEMP` in `init.local`) |
| `Super + B` | Toggle waybar visibility |

### Windows
| Key | Action |
|---|---|
| `Super + J / K` | Focus next / previous |
| `Super + Shift + J / K` | Swap next / previous |
| `Super + Return` | Zoom (promote to main) |
| `Super + Space` | Toggle float |
| `Super + F` | Toggle fullscreen |
| `Super + Q` | Close |

### Layout
| Key | Action |
|---|---|
| `Super + H / L` | Adjust main ratio |
| `Super + Shift + H / L` | Adjust main count |
| `Super + Arrow keys` | Move main panel |

### Floating windows
| Key | Action |
|---|---|
| `Super + Alt + H/J/K/L` | Move |
| `Super + Alt + Ctrl + H/J/K/L` | Snap to edge |
| `Super + Alt + Shift + H/J/K/L` | Resize |
| `Super + Mouse left` | Drag |
| `Super + Mouse right` | Resize |
| `Super + Mouse middle` | Toggle float |

### Tags (workspaces)
| Key | Action |
|---|---|
| `Super + 1–9` | Focus tag |
| `Super + Shift + 1–9` | Move window to tag |
| `Super + Ctrl + 1–9` | Toggle tag focus |
| `Super + Shift + Ctrl + 1–9` | Toggle window's tag |
| `Super + 0` | View all tags |

### Outputs
| Key | Action |
|---|---|
| `Super + . / ,` | Focus next / previous output |
| `Super + Shift + . / ,` | Send window to next / previous output |
| `F7 (XF86Display)` | Cycle display modes (internal → external → extend) |

### Screenshots
| Key | Action |
|---|---|
| `PrtSc` | Full screen to `$XDG_PICTURES_DIR` (falls back to `~/Pictures`) |
| `F10 (XF86SelectiveScreenshot)` | Area to clipboard |
| `Super + Shift + S` | Area with editor (swappy) |

### Function keys
| Key | Action |
|---|---|
| `F1` | Mute |
| `F2` | Volume down |
| `F3` | Volume up |
| `F4` | Mic mute |
| `F5` | Brightness down |
| `F6` | Brightness up |
| `F8` | Cycle power profiles — handled by ThinkPad firmware, no keypress reaches River |
| `F12 (XF86Favorites)` | Htop |
| `Super + F11` | Toggle VM passthrough mode — suspends all River keybinds so the guest receives input directly; `Super + F11` again to exit |

> **Note:** Function key keycodes vary between ThinkPad models and FnLock state. Use [wev](https://git.sr.ht/~sircmpwn/wev) to inspect actual keycodes and adjust `river/init` accordingly.

### System
| Key | Action |
|---|---|
| `Super + Shift + X` | Lock screen |
| `Super + Shift + R` | Reload River config |
| `Super + Shift + E` | Exit River |

### Idle / power
| Timeout | Action |
|---|---|
| 60s | Dim display |
| 120s | Lock screen |
| 180s | Display off |
| 600s | Suspend |

## Idle & Lock

Swayidle manages all idle and sleep behaviour. Wlopm cuts display power at the 180s timeout without removing the output from River, so waylock keeps its surface through display-off and suspend. Swayidle runs with `-w` to hold a systemd sleep inhibitor; waylock runs with `-fork-on-lock` to fully grab the session lock before sleep proceeds.

**Lock screen colours:**
- Locked: `#000000` — black
- Typing: `#333333` — dark grey
- Failed attempt: `#b9162a` — ThinkPad red

## Notifications

Mako runs as a systemd user service, started on login. Configured with a dark theme and ThinkPad red accent for urgency.

- **Dismiss single:** right-click
- **Dismiss all:** middle-click
- **High urgency:** persistent (no timeout), red border
- **Default timeout:** 5 seconds

## Terminal

Foot is configured with:

- Scrollback: 5000 lines
- `$TERM`: `xterm-256color` — if you encounter compatibility issues with terminal apps, this is the first thing to check
- DPI-aware rendering enabled
- Cursor: blinking white beam
- Scroll wheel: scrollback navigation; `Ctrl + scroll` adjusts font size

## PDF Viewer

Zathura uses its default vim-style keybindings for navigation (`j/k` scroll, `gg/G` top/bottom, `/` search, `Tab` cycle links, `Enter` follow link). Only minimal settings are configured — clipboard integration enabled, 10% zoom step.

## System Monitor

Htop is pre-configured with a two-screen layout — the first shows processes sorted by CPU usage with frequency and temperature meters, the second shows I/O activity. This differs from stock htop's default single-screen view.

## Display Scaling

The internal display scale is set via `INTSCALE` in `river/init.local`. Integer scales (1×, 2×) are pixel-perfect but 2× is too large and 1× too small for high-density panels. Fractional scales give a usable middle ground — rounding is imperceptible on dense OLEDs. XWayland apps render at 1× and get upscaled, which can look slightly soft. The logical resolution (native width ÷ scale) affects multi-monitor positioning, which `display-cycle.sh` computes automatically.

## Screenshot Cleanup

`scripts/screenshot-clean.sh` deletes screenshots older than 14 days from your pictures directory. Not wired up automatically — add it to a cron job or systemd timer:

```bash
0 0 * * * ~/thinkpad-river/scripts/screenshot-clean.sh
```

## Uninstall

```bash
rm -f ~/.config/river ~/.config/waybar ~/.config/foot ~/.config/fuzzel
rm -f ~/.config/mako ~/.config/swayidle ~/.config/yazi ~/.config/zathura
rm -f ~/.config/htop ~/.config/fontconfig
rm -f ~/.config/systemd/user/river-session.service
systemctl --user disable mako.service
sudo make -C ~/thinkpad-river/vantage uninstall
```

Adjust the path if you cloned elsewhere, then delete the repo directory.

## Known Limitations

- **`swayidle/config` inline output name** — `wlopm --off <output>` has the output name inlined; swayidle config is not a shell script. The installer patches it from `INT`, but if you change `INT` in `init.local` later you must update `swayidle/config` manually.
- **Waybar configs require re-patching on path changes** — `waybar/config` and `waybar/config-ext` have the repo path and output names patched in by the installer. If you change `CLONEDIR`, `INT`, or `EXT` after the initial install, re-run `install.sh` or update the affected lines manually.
- **Waybar configs are intentionally separate** — `waybar/config` targets the internal display, `waybar/config-ext` the external. A single shared config does not work correctly across outputs. The only differences are the `output` field and the `backlight` module. Changes must be applied to both files.
- **Mako has no output binding** — notifications follow focus; on external-only mode they appear on the external display.

## Troubleshooting

**Display not initializing correctly on startup** — `river/init` delays the `wlr-randr` call by 0.5 seconds. On slower hardware this may not be enough — increase the delay in `river/init` to 1 or 2 seconds if the mode or scale isn't applied on login.

**Function keys not working** — use `wev` to confirm what keysym your hardware emits, then update the binding in `river/init`.

**Input device settings not applying** — run `riverctl list-inputs` and confirm your device identifiers match the values set in `river/init.local`.

**Waybar not appearing or appearing blank on startup** — the init script sends `SIGUSR1` after 1 second to force a refresh. If the bar is still missing, `Super + Shift + R` will restore it.

**`Super + B` hides the bar but leaves a blank strip** — waybar's `"exclusive": true` reserves space regardless of hide state. Switching to `"exclusive": false` removes the strip but causes the bar to overlap content on reveal.

**xdg-desktop-portal not starting** — `river-session.service` must exist in `~/.config/systemd/user/`. See Installation.

**Lock screen not appearing on suspend** — confirm swayidle is running with `-w` (`pgrep -a swayidle`). Without it the system may suspend before waylock launches.

## License

MIT — see [LICENSE](LICENSE).
