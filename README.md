# thinkpad-river

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue?logo=linux&logoColor=white)](https://kernel.org)
[![Wayland](https://img.shields.io/badge/Wayland-Native-brightgreen?logo=wayland&logoColor=white)](https://wayland.freedesktop.org)
[![Compositor: River](https://img.shields.io/badge/Compositor-River-orange)](https://codeberg.org/river/river)
[![Hardware: ThinkPad](https://img.shields.io/badge/Hardware-ThinkPad-red)](https://www.lenovo.com/thinkpad)
[![Kernel: 5.17+](https://img.shields.io/badge/Kernel-5.17%2B-informational?logo=linux&logoColor=white)](https://kernel.org)

A barebones Wayland rice for ThinkPads, built on [River](https://codeberg.org/river/river). No wallpaper, no compositor effects, no decorations — nothing that doesn't serve a direct purpose. Pure black everywhere, subpixel rendering disabled, optimized for OLED panels. TrackPoint, ELAN touchpad, battery thresholds, thermal profiles, and hardware controls are all first-class concerns via [vantage](https://github.com/AdmiralBarbarossa/Minimal-vantage). Keyboard-driven throughout with vim-style navigation.

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
- Wlr-randr (usually bundled with River setups)
- Grim, Slurp, Wl-clipboard, Swappy (screenshots)
- Brightnessctl, Pamixer, Wlsunset, libnotify (notify-send)
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

The installer will ask for your display output names, mode, scale, repo location, and default browser — with your ThinkPad's defaults pre-filled. It then patches all configs in place and installs vantage.

After installation, symlink the configs into `~/.config` (adjust the path if you cloned elsewhere):

```bash
RICE=~/thinkpad-river
ln -sf $RICE/river       ~/.config/river
ln -sf $RICE/waybar      ~/.config/waybar
ln -sf $RICE/foot        ~/.config/foot
ln -sf $RICE/fuzzel      ~/.config/fuzzel
ln -sf $RICE/mako        ~/.config/mako
ln -sf $RICE/yazi        ~/.config/yazi
ln -sf $RICE/zathura     ~/.config/zathura
ln -sf $RICE/htop        ~/.config/htop
ln -sf $RICE/fontconfig  ~/.config/fontconfig
```

> `fontconfig` disables subpixel hinting and LCD filtering — optimised for OLED panels where subpixel rendering causes colour fringing.

## River Defaults

River ships with no keybindings or layout out of the box — everything must be configured explicitly. This rice wires up River's built-in features but does not modify their underlying behaviour:

- **Tiling** — handled by rivertile with zero view padding and zero outer padding (no gaps)
- **Tags** — River's tag system is used as-is; 9 tags configured, tag 1 focused on startup
- **Floating** — River's native float toggle, move, resize, and snap are all standard
- **Passthrough mode** — River's built-in mode system; this rice declares one passthrough mode for VM use
- **Locked mode** — function keys (volume, brightness) remain active on the lock screen via River's `locked` mode mapping

**What was explicitly set:**

- Border: 1px, focused `#707070`, unfocused `#000000` (invisible against black background)
- Key repeat: 50ms delay, 300ms interval
- Layout: rivertile with `-view-padding 0 -outer-padding 0`
- Background: `#000000`
- `GTK_CSD=0` — client-side decorations disabled globally, removing title bars from GTK apps

## Input Devices

Input configuration in `river/init` uses hardware-specific device identifiers for the keyboard, ELAN touchpad, and TrackPoint. These names are tied to the hardware they were written on and may differ on other ThinkPad models. To find your device names:

```bash
riverctl list-inputs
```

Then update the corresponding lines in `river/init` accordingly.

**Touchpad settings (ELAN):**
- Pointer acceleration: 0.6, adaptive profile
- Natural scroll: enabled
- Tap-to-click: enabled
- Click method: clickfinger

**TrackPoint settings:**
- Pointer acceleration: 0.8, adaptive profile

**Keyboard:**
- Layout hardcoded to `us` — change `layout "us"` in `river/init` for other layouts

## Keybindings

### Applications
| Key | Action |
|---|---|
| `Super + Shift + Return` | Terminal (foot) |
| `Super + D` | Launcher (fuzzel) |
| `Super + W` | Browser |
| `Super + E` | File manager (yazi) |
| `XF86Assistant` | File manager (yazi) — ThinkPad AI key |
| `Super + N` | Toggle night light (3200K via wlsunset) |
| `Super + B` | Toggle waybar visibility (bar auto-hides by default, reappears on hover) |

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
| `F9 / PrtSc` | Full screen to `$XDG_PICTURES_DIR` (falls back to `~/Pictures`) |
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
| `F8` | Cycle power profiles (battery saver → balanced → performance) — ThinkPad firmware, no keypress reaches River |
| `F12 (XF86Favorites)` | Htop |
| `Super + F11` | Toggle VM passthrough mode — suspends all River keybinds so the guest receives input directly; `Super + F11` again to exit |

> **Note:** Function key keycodes vary between ThinkPad models and FnLock state. This applies to display cycling and screenshot keys too. The bindings above reflect keysyms as configured — your hardware may emit different codes. Use [wev](https://git.sr.ht/~sircmpwn/wev) to inspect actual keycodes and adjust `river/init` accordingly.

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

## Notifications

Mako is configured with a dark theme and ThinkPad red accent for urgency.

- **Dismiss single:** right-click
- **Dismiss all:** middle-click
- **High urgency:** persistent (no timeout), red border — used for critical system alerts
- **Default timeout:** 5 seconds

## Terminal

Foot is configured with:

- Scrollback: 5000 lines
- `$TERM`: `xterm-256color` — if you encounter compatibility issues with terminal apps, this is the first thing to check
- DPI-aware rendering enabled — scales correctly with fractional scaling
- Cursor: blinking white beam
- Scroll wheel: scrollback navigation; `Ctrl + scroll` adjusts font size

## PDF Viewer

Zathura uses its default vim-style keybindings for navigation (`j/k` scroll, `gg/G` top/bottom, `/` search, `Tab` cycle links, `Enter` follow link). Only minimal settings are configured — clipboard integration enabled, 10% zoom step.

## System Monitor

Htop is pre-configured with a two-screen layout — the first shows processes sorted by CPU usage with frequency and temperature meters, the second shows I/O activity. This differs from stock htop's default single-screen view.

## Display Scaling

The internal display runs at 2880x1800 with a scale of 1.25. At native resolution on a high-density ThinkPad panel, everything would be rendered too small to be practical. Scaling tells the compositor to render the desktop at 1.25× so that UI elements, text, and windows appear at a comfortable size while still benefiting from the panel's high pixel density.

**Why 1.25 and not 2?** Integer scales (1×, 2×) are pixel-perfect — every logical pixel maps exactly to a whole number of physical pixels. 1.25 is fractional, which means some elements get rounded at the pixel boundary. In practice this is imperceptible on a dense OLED panel, and 1.25 gives a better balance between readability and screen real estate than 2× (which would be too large) or 1× (which would be too small).

**Pros:**
- Text and UI are comfortably sized without wasting the panel's resolution
- Native Wayland apps (foot, fuzzel, waybar) render crisply at any scale
- OLED pixel density masks any fractional rounding artifacts

**Cons:**
- XWayland apps do not support fractional scaling natively — they render at 1× and get upscaled, which can look slightly soft
- The logical width of the display becomes 2304px instead of 2880px, which affects multi-monitor positioning (see Known Limitations)

## Screenshot Cleanup

`scripts/screenshot-clean.sh` deletes screenshots older than 14 days from your pictures directory. It is not wired up automatically — add it to a cron job or systemd timer to run periodically:

```bash
# cron example — runs daily at midnight
0 0 * * * ~/thinkpad-river/scripts/screenshot-clean.sh
```

## Uninstall

Remove symlinks and uninstall vantage:

```bash
rm -f ~/.config/river ~/.config/waybar ~/.config/foot ~/.config/fuzzel
rm -f ~/.config/mako ~/.config/yazi ~/.config/zathura ~/.config/htop ~/.config/fontconfig
sudo make -C ~/thinkpad-river/vantage uninstall
```

Adjust the path if you cloned elsewhere, then delete the repo directory.

## Known Limitations

- **`display-cycle.sh` extend position** — in extend mode, both displays share a logical coordinate plane. The external display must be positioned where the internal one ends. The X offset is the internal display's physical width divided by its scale (2880 ÷ 1.25 = 2304), giving `--pos 2304,0` where Y is always 0 for side-by-side layouts. This has nothing to do with the external display's own scale or rendering — it is purely a placement offset. If you install with a different internal resolution or scale, recalculate and update `--pos` in `scripts/display-cycle.sh` accordingly.
- **`swayidle/config` inline output name** — the display-off timeout has the internal output name inlined rather than via a variable (swayidle config is not a shell script). The installer patches it, but manual edits must keep it in sync.
- **Waybar configs are intentionally separate** — `waybar/config` targets the internal display and `waybar/config-ext` targets the external one. A single shared config does not work correctly in a multi-monitor setup, so two files are required. The only meaningful differences are the `output` field and the `backlight` module (internal only). Non-output-specific changes (new modules, style edits) must be applied to both files.
- **Mako has no output binding** — notifications follow focus, so on external-only mode they appear on the external display.

## Troubleshooting

**Display not initializing correctly on startup** — `river/init` delays the `wlr-randr` call by 0.5 seconds to let River finish compositing setup. On slower hardware this may not be enough. If the display mode or scale isn't applied on login, increase the delay in `river/init`:

```bash
sleep 0.5 && wlr-randr ...
# increase to 1 or 2 if needed
sleep 1 && wlr-randr ...
```

**Function keys not working** — use `wev` to confirm what keysym your hardware emits, then update the binding in `river/init`.

**Input device settings not applying** — run `riverctl list-inputs` to confirm your device names match the identifiers in `river/init`.

**Waybar not appearing or appearing blank on startup** — waybar launches before River's IPC socket is fully ready. The init script sends `SIGUSR1` after a 1 second delay to force a refresh. If the bar is missing or empty after login, `Super + Shift + R` to reload River will restore it.

**`Super + B` hides the bar but leaves a blank strip** — waybar's `"exclusive": true` reserves screen space permanently regardless of hide state. This is a waybar limitation; the strip cannot be reclaimed without switching to `"exclusive": false`, which causes the bar to overlap window content on reveal. Current config accepts the strip in exchange for no overlap.

## License

MIT — see [LICENSE](LICENSE).
