#!/bin/bash
RICEDIR="$(dirname "$(readlink -f "$0")")"

ask() {
    local prompt="$1" default="$2" answer
    read -rp "$prompt [$default]: " answer
    echo "${answer:-$default}"
}

echo "thinkpad-river installer"
echo ""

DEPS=(river waybar foot fuzzel mako swayidle waylock wlr-randr wlopm
      grim slurp wl-copy swappy brightnessctl pamixer wlsunset wob
      yazi zathura htop notify-send)

MISSING=()
for dep in "${DEPS[@]}"; do
    command -v "$dep" &>/dev/null || MISSING+=("$dep")
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Missing dependencies: ${MISSING[*]}"
    read -rp "Continue anyway? [y/N]: " CONT
    [[ "$CONT" =~ ^[Yy]$ ]] || exit 1
    echo ""
fi

echo "Press Enter to accept the default value shown in brackets."
echo ""

INT=$(ask      "Internal display output" "eDP-1")
EXT=$(ask      "External display output" "DP-1")
INTMODE=$(ask  "Internal display mode  " "2880x1800@120.000")
INTSCALE=$(ask "Internal display scale " "1.25")
CLONEDIR=$(ask "Repo location          " "$HOME/thinkpad-river")
BROWSER=$(ask  "Default browser        " "firefox")
KBLAYOUT=$(ask "Keyboard layout        " "us")
XCURSOR=$(ask  "Cursor size            " "24")
NLTEMP=$(ask   "Night light temp (K)   " "3200")

echo ""

# Generate river/init.local
cat > "$RICEDIR/river/init.local" << EOF
# --- PREFERENCES ---
BROWSER="$BROWSER"
KBLAYOUT="$KBLAYOUT"
XCURSOR_SIZE=$XCURSOR
WLSUNSET_TEMP=$NLTEMP

# --- DISPLAY ---
INT="$INT"
EXT="$EXT"          # used by scripts/display-cycle.sh
INTMODE="$INTMODE"
INTSCALE="$INTSCALE"

# --- INPUT DEVICES ---
# Fill these in after running: riverctl list-inputs
KEYBOARD=""
TOUCHPAD=""
TRACKPOINT=""       # leave empty if no trackpoint

# --- VA-API / HARDWARE VIDEO DECODE ---
# Only needed if your distro puts the VA-API driver in a non-default path.
# Fedora RPM Fusion nonfree: /usr/lib64/dri-nonfree
# Arch / most distros: leave these unset (system default applies)
#LIBVA_DRIVER_NAME="iHD"
#LIBVA_DRIVERS_PATH="/usr/lib64/dri-nonfree"
#MOZ_SANDBOX_READ_PATH="/usr/lib64/dri-nonfree"
EOF

# Patch swayidle (not a shell script — output name must be inlined)
sed -i "s|eDP-1|$INT|g" "$RICEDIR/swayidle/config"

# Patch waybar output fields and script path
sed -i "s|\"output\": \"eDP-1\"|\"output\": \"$INT\"|" "$RICEDIR/waybar/config"
sed -i "s|\"output\": \"DP-1\"|\"output\": \"$EXT\"|" "$RICEDIR/waybar/config-ext"
sed -i "s|\$HOME/thinkpad-river|$CLONEDIR|g" "$RICEDIR/waybar/config" "$RICEDIR/waybar/config-ext"

echo "Done. Written to river/init.local:"
echo "  Repo location   : $CLONEDIR"
echo "  Internal output : $INT"
echo "  External output : $EXT"
echo "  Mode            : $INTMODE"
echo "  Scale           : $INTSCALE"
echo "  Browser         : $BROWSER"
echo "  Keyboard layout : $KBLAYOUT"
echo "  Cursor size     : $XCURSOR"
echo "  Night light     : ${NLTEMP}K"
echo ""
echo "Next: run 'riverctl list-inputs' and fill in KEYBOARD, TOUCHPAD, TRACKPOINT"
echo "      in river/init.local."
echo ""

VANTAGEDIR="$RICEDIR/vantage"
if [ ! -f "$VANTAGEDIR/Makefile" ]; then
    echo "Vantage submodule not initialized. Run: git submodule update --init"
    exit 1
fi
echo "Installing vantage..."
sudo make -C "$VANTAGEDIR" install
