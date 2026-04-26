# Ghostty Themes

12 custom themes for [Ghostty](https://ghostty.org) terminal, each with a hand-written GLSL shader.

## Themes

| Theme | Vibe | Shader Effect |
|-------|------|---------------|
| **cyberpunk** | Neon synthwave | Wandering pixel bug, glitch tears, chromatic aberration |
| **dude** | Warm sepia bowling alley | Drifting smoke wisps, candle flicker |
| **matrix** | Phosphor green on black | Digital rain with variable-size glyphs |
| **neon** | VHS retro | Neon VHS distortion |
| **pico** | Pico-8 retro 8-bit | Pico drift |
| **pipboy** | Fallout Pip-Boy 3000 | CRT curvature, scanlines, phosphor bloom |
| **aurora** | Northern lights at midnight | Shimmering curtains, starfield |
| **hotdog** | The 1992 Windows legend, made usable | Heat shimmer, mustard splatters |
| **noir** | Film noir detective office | Venetian blind shadows, film grain, cigarette smoke |
| **aquarium** | Deep reef tank at 2 AM | Bioluminescent particles, caustic ripples |
| **campfire** | Embers and stargazing | Rising sparks, firelight flicker |
| **sakura** | Cherry blossom midnight garden | Falling petals, moonlight |

## Install

```bash
# Clone into Ghostty's config directory
git clone https://github.com/snedea/ghostty-themes.git ~/.config/ghostty-themes

# Symlink or copy what you need
cp ~/.config/ghostty-themes/config.campfire ~/.config/ghostty/config
cp -r ~/.config/ghostty-themes/shaders/ ~/.config/ghostty/shaders/
```

Ghostty auto-reloads when the config file changes -- no restart needed.

## Theme Switcher

A shell script for quick switching between themes.

```bash
# Copy the switcher
cp ~/.config/ghostty-themes/theme-switch.sh ~/.config/ghostty/

# Add an alias (bash/zsh)
echo 'alias ghostty-theme="~/.config/ghostty/theme-switch.sh"' >> ~/.zshrc
source ~/.zshrc
```

**Interactive** -- pick from a numbered menu:

```
$ ghostty-theme

Ghostty Themes
──────────────
  ▸ 1) campfire     Campfire -- s'mores, stargazing, and a mass of floating embers
    2) cyberpunk    Cyberpunk -- neon synthwave with wandering bug behind the screen
    3) noir         Noir -- a dark office, a desk lamp, and a case that doesn't add up
    ...
Pick a theme [1-12]:
```

**Direct** -- switch by name:

```bash
ghostty-theme sakura
```

The current theme is marked with `▸` in the menu.

## Writing Your Own Theme

Each theme is two files:

1. **`config.<name>`** -- Ghostty config with colors, cursor, and shader path
2. **`shaders/<name>-<effect>.glsl`** -- GLSL fragment shader

The shader receives the terminal framebuffer as `iChannel0` (sampler2D), plus `iResolution` (vec2), `iTime` (float). Write a `mainImage(out vec4, in vec2)` function. Effects render behind text by masking on luminance:

```glsl
float lum = dot(col, vec3(0.299, 0.587, 0.114));
float darkMask = 1.0 - smoothstep(0.03, 0.18, lum);
// Only draw effects where darkMask > 0 (dark/empty areas)
```

## License

MIT
