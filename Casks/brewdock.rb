cask "brewdock" do
  version "1.1.0"
  sha256 "d24cbd057220dac73e74c0b8b929b719762836842f893640af3e2bc775ac637f"

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
