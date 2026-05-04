# BrewDock

**A free, native macOS menu bar app for Homebrew.** Browse, install, update, and remove your apps and tools without touching the Terminal.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift 6](https://img.shields.io/badge/Swift-6.0-orange) ![License: GPL v3](https://img.shields.io/badge/license-GPL--v3-blue) ![Free](https://img.shields.io/badge/price-free-brightgreen)

---

- **Apps** — all your Homebrew casks with real icons. Click to launch, hover to update or uninstall.
- **Tools** — all your formulae. Click to open in Terminal or iTerm2.
- **Services** — start, stop, and restart Homebrew services on hover.
- **Discover** — browse 150+ curated packages across 10 categories and install with one click.
- **Updates** — badge shows how many packages are outdated. Update one or all at once.
- 100% native SwiftUI — no Electron, no bloat. Liquid Glass UI on macOS 26 Tahoe.

---

## Install

> Homebrew cask coming soon. For now, build from source:

```bash
git clone https://github.com/RossNicholson/homebrew-brewdock.git
cd BrewDock
brew install xcodegen
xcodegen generate
open BrewDock.xcodeproj
```

Press `Cmd+R` in Xcode. The **mug icon** appears in your menu bar.

**Requirements:** macOS 13+ · [Homebrew](https://brew.sh) installed · Apple Silicon or Intel

---

## Contributing

Bug reports, feature requests, and PRs welcome — open an issue or start a discussion.

> No `.xcodeproj` is checked in. Run `xcodegen generate` after cloning.

---

## License

GPL v3 — see [LICENSE](LICENSE) for details.
