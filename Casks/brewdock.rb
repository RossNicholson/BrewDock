cask "brewdock" do
  version "1.1.1"
  sha256 "5deb6656eaf43beb9f369618892d0e4ae0ed2433d612ce6689a8836bfb64ce20"

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
