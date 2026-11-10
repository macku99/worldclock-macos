#!/usr/bin/env bash
# Builds the Release app with its widget and copies it to a signed dist/WorldClock.noindex/WorldClock.app.
#
# SIGNING_IDENTITY is the codesign identity, "WorldClock Local" unless set (see README.md). "-" signs
# ad hoc, which is only good for local checks: an ad-hoc signature changes with every build.
set -euo pipefail

identity="${SIGNING_IDENTITY:-WorldClock Local}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
# Spotlight skips a folder whose name ends in .noindex, so neither the build nor the copy in
# DerivedData shows up beside the installed app.
build_root="dist/WorldClock.noindex"
derived_data="$build_root/DerivedData"
app="$build_root/WorldClock.app"

# Xcode merges the sandbox into the entitlements as a base entitlement, together with get-task-allow,
# which lets a debugger attach. The entitlement files carry the sandbox keys themselves, so the
# injection is turned off. A secure timestamp only matters for notarization, which an owner-only
# build never goes through.
xcodebuild -project WorldClock/WorldClock.xcodeproj -scheme WorldClock -configuration Release \
  -derivedDataPath "$derived_data" \
  CODE_SIGN_IDENTITY="$identity" \
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
  OTHER_CODE_SIGN_FLAGS="--timestamp=none" \
  build

product="$derived_data/Build/Products/Release/WorldClock.app"
rm -rf "$app"
ditto "$product" "$app"
codesign --verify --deep --strict "$app"

# xcodebuild registers its product with Launch Services, and with it the widget. Left registered,
# the system may load the widget from DerivedData instead of the installed app.
"/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister" \
  -u "$product" >/dev/null 2>&1 || true

echo "Built and verified $repo_root/$app (signed by $identity)"
