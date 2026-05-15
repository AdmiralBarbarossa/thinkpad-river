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
      grim slurp wl-copy swappy brightnessctl pamixer wlsunset
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

INT=$(ask     "Internal display output" "eDP-1")
EXT=$(ask     "External display output" "DP-1")
INTMODE=$(ask  "Internal display mode  " "2880x1800@120.000")
INTSCALE=$(ask "Internal display scale " "1.25")
CLONEDIR=$(ask "Repo location          " "$HOME/thinkpad-river")
BROWSER=$(ask  "Default browser        " "librewolf")

echo ""

patchv() {
    local file="$1" var="$2" val="$3"
    sed -i "s|^${var}=.*|${var}=\"${val}\"|" "$file"
    grep -q "^${var}=\"${val}\"" "$file" || echo "Warning: failed to patch $var in $file"
}

for f in "$RICEDIR/river/init" "$RICEDIR/scripts/display-cycle.sh"; do
    patchv "$f" INT      "$INT"
    patchv "$f" EXT      "$EXT"
    patchv "$f" INTMODE  "$INTMODE"
    patchv "$f" INTSCALE "$INTSCALE"
done

patchv "$RICEDIR/river/init" BROWSER "$BROWSER"

sed -i \
    -e "s|eDP-1|$INT|g" \
    -e "s|\$HOME/thinkpad-river|$CLONEDIR|g" \
    "$RICEDIR/swayidle/config"

sed -i \
    -e "s|\$HOME/thinkpad-river|$CLONEDIR|g" \
    "$RICEDIR/waybar/config" \
    "$RICEDIR/waybar/config-ext"

echo "Done. Values written:"
echo "  Internal output : $INT"
echo "  External output : $EXT"
echo "  Mode            : $INTMODE"
echo "  Scale           : $INTSCALE"
echo "  Repo location   : $CLONEDIR"
echo "  Browser         : $BROWSER"

echo ""
VANTAGEDIR="$RICEDIR/vantage"
if [ ! -f "$VANTAGEDIR/Makefile" ]; then
    echo "Vantage submodule not initialized. Run: git submodule update --init"
    exit 1
fi
echo "Installing vantage..."
sudo make -C "$VANTAGEDIR" install
