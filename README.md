# BrewDock — Homebrew for the rest of us

**A free, native macOS menu bar app that turns Homebrew into a point-and-click experience.**

Browse, install, update, and remove your Homebrew apps and tools without touching the Terminal. BrewDock lives quietly in your menu bar and is always one click away.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift 6](https://img.shields.io/badge/Swift-6.0-orange) ![License: GPL v3](https://img.shields.io/badge/license-GPL--v3-blue) ![Free](https://img.shields.io/badge/price-free-brightgreen)

---

## Why BrewDock?

Homebrew is the backbone of most Mac developer setups — but managing it day-to-day means remembering commands, opening Terminal, and squinting at text output. BrewDock fixes that.

- **100% native SwiftUI** — no Electron, no web views, no bloat. Feels right at home on macOS.
- **Always one click away** — tucked in your menu bar, never cluttering your Dock.
- **See outdated packages at a glance** — a badge tells you how many updates are waiting.
- **Discover 150+ popular apps** — browse curated categories and install with one click.
- **Completely free and open source** — GPL v3, no paywalls, no subscriptions.

---

## What it does

### Apps
All your Homebrew casks in one list, with real app icons. Click any app to launch it. Hover to update or uninstall — BrewDock will even offer to quit a running app before removing it.

### Tools
All your Homebrew formulae with smart icons. Click any tool to open it in a new Terminal window (or iTerm2 if you have it installed).

### Services
All your Homebrew-managed services (PostgreSQL, Redis, nginx, etc.) in one place. Hover to start, stop, or restart — no more `brew services` commands.

### Discover
Browse 150+ curated packages across 10 categories — Browsers, Development, AI & ML, Databases, DevOps & Cloud, Media & Design, Productivity, Communication, Security, and Utilities. Every package shows its real icon fetched from the web. Click Install and walk away.

### Updates
An orange badge in the header shows how many packages are out of date. Update them individually on hover, or hit **Update All** to do everything at once.

---

## Features at a glance

| | |
|---|---|
| Real app icons everywhere | SF Symbols for CLI tools |
| Instant search on every tab | Resizable, draggable panel |
| One-click install from Discover | Hover-to-uninstall with running app detection |
| Services management | Launch at Login |
| Auto-update via Sparkle | Liquid Glass UI on macOS 26 Tahoe |

---

## Requirements

- macOS 13 Ventura or later (macOS 26 Tahoe supported with Liquid Glass UI)
- [Homebrew](https://brew.sh) installed — Apple Silicon and Intel both supported

---

## Installation

> **Homebrew cask coming soon** — for now, build from source in about 60 seconds.

```bash
git clone https://github.com/RossNicholson/BrewDock.git
cd BrewDock
brew install xcodegen
xcodegen generate
open BrewDock.xcodeproj
```

Press `Cmd+R` in Xcode to build and run. The **mug icon** will appear in your menu bar.

---

## Quick start

| What you want to do | How |
|---|---|
| Launch a GUI app | Click it in the **Apps** tab |
| Open a CLI tool | Click it in the **Tools** tab |
| Start / stop a service | Hover it in the **Services** tab |
| Install something new | Browse **Discover** and click Install |
| Uninstall a package | Hover it → click the trash icon |
| Update one package | Hover it → click the orange arrow |
| Update everything | Click the **Update N** badge in the header |
| Search | Start typing — filters the active tab instantly |
| Resize the panel | Drag any edge or corner |
| Move the panel | Drag the handle at the top |
| Settings | Click the **gear icon** in the header |

---

## Contributing

BrewDock is early-stage and improving fast. Bug reports, feature requests, and pull requests are all welcome — open an issue or start a discussion.

The project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) so there's no checked-in `.xcodeproj`. Run `xcodegen generate` after pulling to regenerate it.

---

## Project structure

```
BrewDock/
├── AppDelegate.swift       # NSStatusItem + NSPanel setup
├── BrewDockApp.swift       # App entry point
├── BrewService.swift       # Homebrew data layer
├── MenuBarView.swift       # Main panel UI
├── PackageRowView.swift    # Individual package row
├── ServiceRowView.swift    # Individual service row
├── DiscoverView.swift      # Discover tab UI
├── DiscoverPackage.swift   # Discover package model + curated catalog
├── FormulaIcons.swift      # SF Symbol icon map for formulae
├── SettingsView.swift      # Settings popover
└── View+Glass.swift        # Liquid Glass / material helpers
```

---

## Roadmap

- [ ] Homebrew cask distribution (`brew install --cask brewdock`)
- [ ] Sparkle auto-update signing
- [ ] Package detail view with version history
- [ ] Notification when updates are available

---

## License

GPL v3 — see [LICENSE](LICENSE) for details.
