cask "brewdock" do
  version "1.1.3"
  sha256 "ca9e78fba776b905063b5a809fb4c7805ec124fbf8d13a5dc934b1d1f01718b8"

  url "https://github.com/RossNicholson/homebrew-brewdock/releases/download/v#{version}/BrewDock-#{version}.dmg"
  name "BrewDock"
  desc "Native macOS menu bar app for Homebrew"
  homepage "https://github.com/RossNicholson/homebrew-brewdock"

  depends_on macos: ">= :ventura"

  app "BrewDock.app"

  zap trash: [
    "~/Library/Application Support/BrewDock",
    "~/Library/Preferences/com.rossnicholson.BrewDock.plist",
    "~/Library/Caches/com.rossnicholson.BrewDock",
  ]
end
