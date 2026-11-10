#!/usr/bin/env bash
# Replaces ~/Applications/WorldClock.app with the build in dist/, opens it, then removes the build.
#
# Only a build whose app and widget are both signed by "WorldClock Local" may replace the installed
# app, so the signature stays the same from one install to the next. The new app is copied beside
# the installed one first, so a failed copy leaves the installed app untouched.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_app="$repo_root/dist/WorldClock.noindex/WorldClock.app"
install_path="$HOME/Applications/WorldClock.app"
staging="$install_path.installing"
previous="$install_path.previous"
identity="WorldClock Local"
widget_process="WorldClockWidgetExtensionExtension"

[[ -d "$source_app" ]] || { echo "error: $source_app does not exist; run scripts/build-app.sh first" >&2; exit 1; }

require_signed_by_identity() {
  local bundle="$1" details authority
  # codesign fails on an unsigned bundle; the check below reports it.
  details="$(codesign -dvv "$bundle" 2>&1 || true)"
  if ! grep -qx "Authority=$identity" <<<"$details"; then
    authority="$(grep -m1 '^Authority=' <<<"$details" | cut -d= -f2- || true)"
    echo "error: $bundle is not signed by $identity (Authority: ${authority:-none, ad hoc or unsigned})" >&2
    exit 1
  fi
}
require_signed_by_identity "$source_app"
require_signed_by_identity "$source_app/Contents/PlugIns/$widget_process.appex"

mkdir -p "$(dirname "$install_path")"
rm -rf "$staging" "$previous"
ditto "$source_app" "$staging"

# pkill exits 1 when WorldClock is not running, which is fine.
pkill -x WorldClock || true
for _ in {1..50}; do
  pgrep -x WorldClock >/dev/null || break
  sleep 0.1
done
if pgrep -x WorldClock >/dev/null; then
  echo "error: WorldClock did not quit; the installed app is unchanged" >&2
  rm -rf "$staging"
  exit 1
fi

[[ -d "$install_path" ]] && mv "$install_path" "$previous"
if ! mv "$staging" "$install_path"; then
  echo "error: could not move the new app into place" >&2
  # Put the old app back first, so a failed swap never leaves the install path empty.
  if [[ -d "$previous" ]]; then
    if mv "$previous" "$install_path"; then
      echo "The previous app is back at $install_path" >&2
    else
      echo "error: the previous app is still at $previous; move it back by hand" >&2
    fi
  fi
  rm -rf "$staging" || true
  exit 1
fi
rm -rf "$previous"

# A widget extension that is still running keeps serving the old code until it exits.
pkill -x "$widget_process" || true
open "$install_path"

# The build has the same bundle IDs as the installed app and its widget. Left registered, the system
# may load the widget from the build. Cleanup runs after the app is open, so it can't undo the install.
"/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister" \
  -u "$source_app" >/dev/null 2>&1 || true
rm -rf "$source_app" || echo "warning: could not remove $source_app" >&2
echo "Installed $install_path"
