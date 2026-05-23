#!/bin/bash
#
# cut-release.sh X.Y.Z — the one safe way to ship a release.
#
# Bumps the version, commits, tags vX.Y.Z, and pushes. CI (.github/workflows/
# release.yml) then builds, signs, notarizes, publishes, and bumps the tap.
# Guard rails refuse to run on a dirty tree, off main, with a bad version, or a
# tag that already exists — so there's nothing to get wrong by hand.
set -euo pipefail

VERSION="${1:-}"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "usage: $(basename "$0") X.Y.Z"; exit 1; }

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

fail() { echo "ERROR: $1" >&2; exit 1; }

[[ "$(git rev-parse --abbrev-ref HEAD)" == "main" ]] || fail "not on main"
git diff --quiet && git diff --cached --quiet           || fail "working tree not clean — commit or stash first"
! git rev-parse "v$VERSION" >/dev/null 2>&1             || fail "tag v$VERSION already exists"

if [[ -f project.yml ]]; then
  # XcodeGen: bump the marketing version, increment the build number, regenerate.
  /usr/bin/sed -i '' -E "s/CFBundleShortVersionString: \"[^\"]*\"/CFBundleShortVersionString: \"$VERSION\"/" project.yml
  CUR="$(/usr/bin/sed -nE 's/.*CFBundleVersion: "([0-9]+)".*/\1/p' project.yml | head -1)"
  /usr/bin/sed -i '' -E "s/CFBundleVersion: \"[0-9]*\"/CFBundleVersion: \"$(( ${CUR:-0} + 1 ))\"/" project.yml
  command -v xcodegen >/dev/null && xcodegen generate >/dev/null
  git add -u            # stages project.yml + regenerated Info.plist/pbxproj (tracked only)
else
  # Raw Xcode project: bump MARKETING_VERSION in the pbxproj.
  PBX="$(ls -d ./*.xcodeproj/project.pbxproj | head -1)"
  [[ -f "$PBX" ]] || fail "no project.yml and no .xcodeproj/project.pbxproj found"
  /usr/bin/sed -i '' -E "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $VERSION;/g" "$PBX"
  git add "$PBX"
fi

git diff --cached --quiet && fail "version bump produced no change — is it already v$VERSION?"

git commit -m "Bump to v$VERSION"
git tag "v$VERSION"
git push origin main
git push origin "v$VERSION"

echo ""
echo "Pushed v$VERSION. CI is now building, notarizing, releasing, and bumping the tap."
echo "Watch it:  gh run watch \$(gh run list --workflow=release.yml --limit 1 --json databaseId --jq '.[0].databaseId')"
