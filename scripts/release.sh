#!/bin/bash
#
# release.sh — build, sign, notarize, staple, and (optionally) publish BrewDock.
#
# This encodes the manual release pipeline so notarization can't be skipped
# (v1.0.6 shipped un-notarized because a manual step was missed). It fails hard
# if anything — signing, notarization, stapling, or Gatekeeper — doesn't pass.
#
# Usage:
#   scripts/release.sh            # build a notarized, stapled DMG; print next steps
#   scripts/release.sh --publish  # also create the GitHub release and bump the tap
#
# Prerequisites (one-time, on this machine):
#   - "Developer ID Application: Ross Nicholson (5HQ5V9NP82)" cert in the keychain
#   - notarytool keychain profile named "notarytool"
#       (xcrun notarytool store-credentials notarytool --apple-id … --team-id … --password …)
#   - gh authenticated (for --publish)
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAP="$(cd "$REPO/.." && pwd)/homebrew-tap"
GH_REPO="RossNicholson/brewdock"
PROFILE="notarytool"
cd "$REPO"

PUBLISH=0
[[ "${1:-}" == "--publish" ]] && PUBLISH=1

step() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
fail() { printf '\n\033[1;31mERROR:\033[0m %s\n' "$1" >&2; exit 1; }

step "Syncing Xcode project from project.yml"
command -v xcodegen >/dev/null || fail "xcodegen not installed (brew install xcodegen)"
xcodegen generate

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' BrewDock/Info.plist)"
[[ -n "$VERSION" ]] || fail "could not read version from Info.plist"
DMG="build/BrewDock-$VERSION.dmg"
step "Releasing BrewDock $VERSION"

step "Running tests"
xcodebuild test -project BrewDock.xcodeproj -scheme BrewDock \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO -quiet \
  || fail "tests failed"

step "Archiving (Release)"
rm -rf build/BrewDock.xcarchive build/export "$DMG" build/dmg-staging
xcodebuild -project BrewDock.xcodeproj -scheme BrewDock -configuration Release \
  -archivePath build/BrewDock.xcarchive archive -quiet || fail "archive failed"

step "Exporting signed app"
xcodebuild -exportArchive -archivePath build/BrewDock.xcarchive \
  -exportPath build/export -exportOptionsPlist ExportOptions.plist -quiet || fail "export failed"

APP="build/export/BrewDock.app"
# Capture then string-match: piping codesign into `grep -q` races under
# `pipefail` (grep exits on match, codesign dies with SIGPIPE -> false failure).
SIGN_INFO="$(codesign -dvvv "$APP" 2>&1)"
[[ "$SIGN_INFO" == *"Authority=Developer ID Application"* ]] \
  || fail "app is not Developer ID signed"

step "Building DMG ($DMG)"
mkdir -p build/dmg-staging
cp -R "$APP" build/dmg-staging/
hdiutil create -volname "BrewDock" -srcfolder build/dmg-staging -ov -format UDZO "$DMG" >/dev/null
rm -rf build/dmg-staging

step "Notarizing (this can take a few minutes)"
# CI passes an App Store Connect API key via env; locally we use the stored
# notarytool keychain profile.
if [[ -n "${NOTARY_KEY_P8:-}" && -n "${NOTARY_KEY_ID:-}" && -n "${NOTARY_ISSUER_ID:-}" ]]; then
  SUBMIT="$(xcrun notarytool submit "$DMG" --key "$NOTARY_KEY_P8" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER_ID" --wait 2>&1)"
else
  SUBMIT="$(xcrun notarytool submit "$DMG" --keychain-profile "$PROFILE" --wait 2>&1)"
fi
echo "$SUBMIT"
[[ "$SUBMIT" == *"status: Accepted"* ]] || fail "notarization was not Accepted"

step "Stapling and verifying"
xcrun stapler staple "$DMG" || fail "stapling failed"
xcrun stapler validate "$DMG" >/dev/null || fail "staple validation failed"
# The meaningful Gatekeeper check is on the app inside the DMG.
MP="$(hdiutil attach -nobrowse -readonly "$DMG" | grep Volumes | awk '{print $3}')"
ASSESS="$(spctl -a -vvv -t exec "$MP/BrewDock.app" 2>&1 || true)"
hdiutil detach "$MP" -quiet
[[ "$ASSESS" == *"Notarized Developer ID"* ]] \
  || { echo "$ASSESS"; fail "app inside DMG is not notarized/accepted"; }

SHA="$(shasum -a 256 "$DMG" | awk '{print $1}')"
step "Done: notarized DMG ready"
printf '   File:   %s\n   SHA256: %s\n' "$DMG" "$SHA"

if [[ "$PUBLISH" -eq 0 ]]; then
  cat <<EOF

Not published (re-run with --publish to do these automatically):
  git tag v$VERSION && git push origin v$VERSION
  gh release create v$VERSION "$DMG" --repo $GH_REPO --title "v$VERSION"
  # then in $TAP/Casks/brewdock.rb set version "$VERSION" and sha256 "$SHA", commit, push
EOF
  exit 0
fi

step "Publishing v$VERSION to GitHub"
command -v gh >/dev/null || fail "gh not installed"
# In CI the tag already exists (it triggered the run); locally it doesn't yet.
if ! git rev-parse "v$VERSION" >/dev/null 2>&1; then
  git tag "v$VERSION"
  git push origin "v$VERSION"
fi
gh release create "v$VERSION" "$DMG" --repo "$GH_REPO" --title "v$VERSION" --generate-notes

step "Bumping Homebrew tap cask"
# Locally the tap is a sibling checkout; in CI we clone it with the push token.
if [[ ! -d "$TAP" ]]; then
  [[ -n "${TAP_PUSH_TOKEN:-}" ]] || fail "tap not found at $TAP and no TAP_PUSH_TOKEN to clone it"
  git clone "https://x-access-token:${TAP_PUSH_TOKEN}@github.com/RossNicholson/homebrew-tap.git" "$TAP"
fi
CASK="$TAP/Casks/brewdock.rb"
/usr/bin/sed -i '' -E "s/^  version \".*\"/  version \"$VERSION\"/; s/^  sha256 \".*\"/  sha256 \"$SHA\"/" "$CASK"
git -C "$TAP" add Casks/brewdock.rb
git -C "$TAP" commit -m "Bump brewdock to v$VERSION"
git -C "$TAP" push origin main

step "Published v$VERSION ✅"
