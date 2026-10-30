#!/bin/bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for script in "$project_root/build.sh" "$project_root"/scripts/*.sh; do
    bash -n "$script"
done
plutil -lint "$project_root/Resources/Info.plist"
"$project_root/scripts/build.sh"
app_name=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$project_root/Resources/Info.plist")
app="${BUILD_DIR:-$project_root/build}/$app_name.app"
codesign --verify --strict "$app"
if [ "${ARCHS:-}" = universal ]; then
    case "$(xcrun lipo -archs "$app/Contents/MacOS/$app_name")" in
        'arm64 x86_64'|'x86_64 arm64') ;;
        *) printf 'Expected both arm64 and x86_64 in the application.\n' >&2; exit 1 ;;
    esac
fi
test -s "$app/Contents/Resources/AppIcon.icns"
test -s "$app/Contents/Resources/LICENSE"
# This command reads status only; it does not launch the menu or register login.
"$app/Contents/MacOS/$app_name" --status | /usr/bin/python3 -c '
import json, sys
status = json.load(sys.stdin)
assert type(status.get("visible")) is bool, "Missing visibility status"
assert type(status.get("loginStatus")) is int, "Missing login status"
assert set(status) == {"visible", "loginStatus", "hasLastError", "version"}, "Unexpected diagnostic fields"
assert type(status["hasLastError"]) is bool, "Missing error flag"
assert isinstance(status["version"], str), "Missing version"
'
printf 'Build, signature, resources, and read-only status check passed.\n'
