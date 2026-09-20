# MiniCal

A lightweight native macOS menu bar calendar — inspired by the Ubuntu/GNOME clock popup.

![macOS](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## What it does

Click the date in your menu bar → a clean monthly calendar appears instantly.

- **Menu bar icon** showing the current day (e.g. `Sat 20`)
- **Monthly calendar popup** with today highlighted
- **Previous / next month** navigation, plus a **Today** button
- **Full keyboard navigation**
- **No Dock icon**, no app windows — lives entirely in the menu bar
- **Launches at login** automatically
- **Dark Mode** and **VoiceOver** supported

## Keyboard shortcuts

| Key | Action |
|---|---|
| `←` `→` | Move one day |
| `↑` `↓` | Move one week |
| `Page Up` / `Page Down` | Previous / next month |
| `T` | Jump to today |

Arrowing past the end of a month moves the view into the next one automatically.

## Screenshot

```
┌────────────────────────┐
│  ‹     June 2026    ›  │
│ Su Mo Tu We Th Fr Sa   │
│     1  2  3  4  5  6   │
│  7  8  9 10 11 12 13   │
│ 14 15 16 17 18 19 (20) │  ← today
│ 21 22 23 24 25 26 27   │
│ 28 29 30               │
│         Today          │
└────────────────────────┘
```

## Installation

### Homebrew (recommended)

```bash
brew install --cask thedeceptio/tap/minical
xattr -cr /Applications/MiniCal.app
```

The second line is required — see [First launch](#first-launch--macos-will-block-it)
below for why. Then launch MiniCal from `/Applications` or Spotlight.

To update later:

```bash
brew upgrade --cask minical
```

### Manual download

1. Download **MiniCal.zip** from the [latest release](../../releases/latest)
2. Unzip and drag **MiniCal.app** to your `/Applications` folder
3. Double-click to launch

### First launch — macOS will block it

MiniCal isn't notarized (that requires a paid Apple Developer account), so macOS
refuses to open it until you clear the quarantine flag. This applies to Homebrew
installs too.

**Run this once, after installing:**

```bash
xattr -cr /Applications/MiniCal.app
```

Then open the app normally.

<details>
<summary>Prefer not to use Terminal?</summary>

Double-click `MiniCal.app` and let it fail, then go to **System Settings →
Privacy & Security**, scroll to the Security section, and click **Open Anyway**
next to the message about MiniCal.

Note that Control-clicking the app and choosing **Open** — the old workaround —
no longer bypasses Gatekeeper on macOS Sequoia and later.

</details>

## Requirements

- macOS 14 (Sonoma) or later
- Apple Silicon or Intel Mac

## Build from source

```bash
git clone https://github.com/thedeceptio/MiniCal.git
cd MiniCal
xcodegen generate
open MiniCal.xcodeproj
```

Then press **Cmd+R** in Xcode.

**Requires:** Xcode 15+, [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Architecture

| File | Purpose |
|---|---|
| `MiniCalApp.swift` | App entry point, `MenuBarExtra`, login item registration |
| `CalendarModel.swift` | Calendar logic — grid generation, month navigation |
| `CalendarView.swift` | SwiftUI popup view |
| `MenuBarLabel.swift` | Menu bar label, updates daily |

Built with SwiftUI `MenuBarExtra` (.window style) and Foundation Calendar APIs. No external dependencies.

## License

MIT — do whatever you want with it.
