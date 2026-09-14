<p align="center"><img src="assets/grove-mark.svg" width="64" alt="Grove leaf mark"></p>

# Bone Grove · Emerald

A quiet, dark Omarchy experience built around **Emerald Ronin in the Mist**: near-black stone, mist-gray text and restrained emerald highlights.

![Grove Emerald lock-screen preview running on Omarchy](preview.png)

## Install

For wallpaper, palette, shell surfaces and icons:

```bash
omarchy theme install https://github.com/jonahchang207/omarchy-bone-grove-theme
```

For the complete experience, including the bar, screensaver, lock-screen styling and controls:

```bash
git clone https://github.com/jonahchang207/omarchy-bone-grove-theme.git
cd omarchy-bone-grove-theme
python3 install.py --full --dry-run
python3 install.py --full
```

Requires **Omarchy 4 with Lua Hyprland and Quickshell**, tested on 4.0.2-1. The full installer backs up replaced files, preserves idle times and unrelated plugins, and writes only within your home directory. Existing Grove size, opacity and motion preferences survive updates. It uses the installed Omarchy lock service's authentication code, with a customized view.

## The experience

- **Canopy bar:** three small floating capsules, sliding workspace rail, clock and native monitor control. Disconnected Bluetooth collapses until you hover over the bar; icons retain their native descriptive tooltips.
- **Grove Controls:** sound, brightness, Wi-Fi, Bluetooth and night light in one compact panel. Native connection and display panels remain a click away.
- **Graphical screensaver:** crisp time and date in the artwork's open left side, a subtle emerald light cycle, and a short dismissal fade. Keyboard, click, scroll or mouse movement dismisses it.
- **Matching lock screen:** the same artwork and clock placement, plus a minimal password field. Native PAM, fingerprint authentication, session locking and recovery stay in Omarchy's service.
- **Motion:** coordinated window, workspace and layer transitions; shorter departures; interruptible popup fades. Quick, Balanced, Soft and Off presets.
- **Appearance:** bar height from 24–40 px and opacity from 75–100%. Default: 30 px and 94%.

## Everyday use

| Action | Result |
| --- | --- |
| Click GROVE | Omarchy menu |
| Right-click GROVE | Screensaver preview |
| Middle-click GROVE | Reduced-motion toggle |
| Click the controls icon | Grove Controls |
| Right-click the controls icon | Appearance settings |
| Search “Grove Appearance” | Appearance settings |
| Click the monitor icon | Native display controls |
| Scroll over workspaces | Previous/next workspace |

```bash
bone-grove settings
bone-grove set motion .65   # Quick; also 0, 1, 1.2
bone-grove set size 30
bone-grove set opacity .94
bone-grove update
bone-grove restore          # Restore the latest installer backup
```

To restore a particular checkpoint:

```bash
python3 install.py --restore /path/to/backup
```

Restore replaces the affected files with their saved originals, including the former theme and shell settings. Save any later edits you want to keep first.

The native idle launch and `omarchy launch screensaver` use the graphical renderer. The screensaver retains Omarchy's application ID so idle tracking and the transition to locking continue to work. Stay Awake and the screensaver-disabled preference are respected. A screensaver is not a session lock. Always-on-top application windows may remain above the ambient screensaver; the secure session lock covers applications.

## Palette

| Surface | Color |
| --- | --- |
| Near black | `#060B08` |
| Forest surface | `#0D1511` |
| Raised surface | `#18271F` |
| Selection | `#254336` |
| Emerald | `#86C8A3` |
| Mist | `#E1EBE4` |

## Scope and validation

The experience styles the compositor, bar, shell, supported application themes, screensaver and lock view. Applications still control their internal scrolling and animation. The authored bar layout is horizontal; native vertical fallback remains available. Shell API changes may require updating custom plugins.

```bash
python3 -m unittest discover -s tests -v
hyprctl configerrors
```

Checks cover installation, dry-run, exact backup restoration, preference validation and preserving unrelated settings. Live checks covered graphical rendering/dismissal, control and appearance panels, and a lock-screen **preview**. The authentication service remains unmodified; no authentication test is claimed.

Code is MIT licensed. See [NOTICE.md](NOTICE.md) for artwork and upstream attribution. No Apple or Omarchy affiliation is implied.
