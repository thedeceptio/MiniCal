# MiniCal

A lightweight native macOS menu bar calendar — inspired by the Ubuntu/GNOME clock popup.

![macOS](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## What it does

Click the date in your menu bar → a clean monthly calendar appears instantly.

- **Menu bar icon** showing the current day (e.g. `Sat 20`)
- **Monthly calendar popup** with today highlighted
- **Previous / next month** navigation
- **No Dock icon**, no app windows — lives entirely in the menu bar
- **Launches at login** automatically
- **Dark Mode** supported

## Screenshot

```
┌────────────────────────┐
│       June 2026        │
│  <                >    │
│ Su Mo Tu We Th Fr Sa   │
│  1  2  3  4  5  6  7   │
│  8  9 10 11 12 13 14   │
│ 15 16 17 18 19 [20] 21 │  ← today
│ 22 23 24 25 26 27 28   │
│ 29 30                  │
└────────────────────────┘
```

## Installation

1. Download **MiniCal.zip** from the [latest release](../../releases/latest)
2. Unzip and drag **MiniCal.app** to your `/Applications` folder
3. Double-click to launch

### First launch — Gatekeeper warning

macOS may show *"MiniCal can't be opened because it's from an unidentified developer."*

**Fix:** Right-click (or Control+click) `MiniCal.app` → click **Open** → click **Open** again.
You only need to do this once.

Alternatively, run in Terminal:
```bash
xattr -cr /Applications/MiniCal.app
```

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
