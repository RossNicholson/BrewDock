cask "brewdock" do
  version "1.1.2"
  sha256 "b01bb8731c76d0d25e744c43d67de6d9ceffe007124007e5693051b518a784e5"

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
