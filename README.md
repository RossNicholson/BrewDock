# BrewDock

A native macOS menu bar app for Homebrew. See, launch, install, and manage everything you've installed with brew — without touching the terminal.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![License](https://img.shields.io/badge/license-GPL--v3-blue)

## Features

- **Apps tab** — lists all your Homebrew casks with their real app icons. Click to launch.
- **Tools tab** — lists all your Homebrew formulae with SF Symbol icons. Click to open in a new Terminal window (or iTerm2 if installed).
- **Services tab** — lists all Homebrew-managed services. Hover to start, stop, or restart.
- **Discover tab** — browse 85+ popular packages across 9 categories and install with one click.
- **Updates** — shows outdated packages with a badge. Update individual packages on hover, or update everything at once.
- **Uninstall** — hover any package and click the trash icon to uninstall. Detects running apps and offers to quit them first.
- **Search** — filter instantly across whichever tab you're on.
- **Settings** — gear icon with Launch at Login toggle and check for updates.
- **Resizable** — drag any edge or corner to resize the panel.
- **Liquid Glass** — native Liquid Glass UI on macOS 26 Tahoe, with automatic fallback on earlier versions.

## Requirements

- macOS 13 (Ventura) or later
- [Homebrew](https://brew.sh) installed (Apple Silicon and Intel both supported)

## Installation

> Distribution via Homebrew cask coming soon.

For now, build from source:

```bash
git clone https://github.com/RossNicholson/BrewDock.git
cd BrewDock
brew install xcodegen
xcodegen generate
open BrewDock.xcodeproj
```

Then build and run in Xcode with `Cmd+R`. BrewDock will appear as a mug icon in your menu bar.

## Usage

Click the **mug icon** in the menu bar to open the panel.

| Action | How |
|---|---|
| Launch a GUI app | Click it in the Apps tab |
| Open a CLI tool | Click it in the Tools tab — opens Terminal or iTerm2 |
| Start/stop a service | Hover it in the Services tab |
| Install a new package | Browse the Discover tab and click Install |
| Uninstall a package | Hover it and click the trash icon |
| Update a package | Hover it and click the orange arrow |
| Update everything | Click the orange **Update N** badge in the header |
| Refresh the list | Click the refresh button in the header |
| Resize the panel | Drag any edge or corner |
| Move the panel | Drag the handle at the top |
| Settings | Click the gear icon in the header |

## Project Structure

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

## Roadmap

- [ ] Homebrew cask distribution
- [ ] Sparkle auto-update signing setup

## License

GPL v3 — see [LICENSE](LICENSE) for details.
