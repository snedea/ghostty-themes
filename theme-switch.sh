#!/usr/bin/env bash
# Ghostty theme switcher
# Usage: ghostty-theme [theme-name]

GHOSTTY_DIR="$HOME/.config/ghostty"
CONFIG="$GHOSTTY_DIR/config"

# Gather themes from config.* files
themes=()
descs=()
for f in "$GHOSTTY_DIR"/config.*; do
  [ -f "$f" ] || continue
  name="${f##*/config.}"
  desc=$(grep -m1 '^# ' "$f" | sed 's/^# //')
  themes+=("$name")
  descs+=("$desc")
done

if [ ${#themes[@]} -eq 0 ]; then
  echo "No themes found in $GHOSTTY_DIR/config.*"
  exit 1
fi

# Detect current theme
current=""
for t in "${themes[@]}"; do
  if diff -q "$CONFIG" "$GHOSTTY_DIR/config.$t" &>/dev/null; then
    current="$t"
    break
  fi
done

# Direct selection by name
if [ -n "$1" ]; then
  for i in "${!themes[@]}"; do
    if [ "${themes[$i]}" = "$1" ]; then
      cp "$GHOSTTY_DIR/config.$1" "$CONFIG"
      echo "Switched to: $1 -- ${descs[$i]}"
      exit 0
    fi
  done
  echo "Unknown theme: $1"
  echo "Available: ${themes[*]}"
  exit 1
fi

# Interactive menu
echo "Ghostty Themes"
echo "──────────────"
for i in "${!themes[@]}"; do
  marker="  "
  [ "${themes[$i]}" = "$current" ] && marker="▸ "
  printf "  %s%d) %-12s %s\n" "$marker" $((i + 1)) "${themes[$i]}" "${descs[$i]}"
done
echo ""
printf "Pick a theme [1-%d]: " "${#themes[@]}"
read -r choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#themes[@]}" ]; then
  echo "Cancelled."
  exit 1
fi

idx=$((choice - 1))
cp "$GHOSTTY_DIR/config.${themes[$idx]}" "$CONFIG"
echo "Switched to: ${themes[$idx]} -- ${descs[$idx]}"
